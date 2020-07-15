"""Remote Console"""
import sys
import socket
import traceback

PACKING_BYTES = b'\xFF\xFF\xFF\xFF'
BUFFER_SIZE = 10240
SOCKET_TIMEOUT = 4


def usage():
	print('Quake Remote Console (part of AGRIP AudioQuake)')
	print('Usage:', sys.argv[0], '[host port]')


def logbuildcommand_to_send():
	# leaving out the \n or having \x00 works too
	return command_core('log\n')


def buildcommand_to_send(command, password):
	return command_core('rcon ' + password + ' ' + command + '\x00')


def command_core(processed):
	return PACKING_BYTES + bytes(processed, 'ascii')


def filter_response(received):
	if received.startswith(PACKING_BYTES):
		return received[5:].rstrip().decode()  # an 'n' follows the padding
	else:
		return received.rstrip().decode()


def get_host_and_port():
	if len(sys.argv) == 1:
		# Ask user for host and port (used when run from launcher)
		host = input('Server hostname or IP [default: localhost]: ') \
			or 'localhost'
		port = input('Server port [default: 27500]: ') or '27500'
		port = int(port)
	elif len(sys.argv) == 3:
		# Get the values from the command line
		host = sys.argv[1] if len(sys.argv) > 1 else 'localhost'
		try:
			port = int(sys.argv[2]) if len(sys.argv) > 2 else 27500
		except ValueError:
			print('Error: port number is not an integer')
			sys.exit(1)
	else:
		# Improper invocation
		usage()
		if len(sys.argv) > 1 \
			and (sys.argv[1] == '-h' or sys.argv[1] == '--help'):
			sys.exit(0)
		else:
			sys.exit(1)

	return (host, port)


def create_socket(host, port):
	try:
		# It'd be nice to use the values from getaddrinfo() to directly create
		# the socket.
		socket.getaddrinfo(host, port, type=socket.SOCK_DGRAM)
		sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		sock.settimeout(SOCKET_TIMEOUT)
		return sock
	except socket.gaierror as e:
		print(e)
		sys.exit(1)


if __name__ == '__main__':
	address = get_host_and_port()
	sock = create_socket(*address)

	password = input('Server rcon password [default: rconpasswd]: ') \
		or 'rconpasswd'

	print("Ready to talk: 'quit' shuts down the server; 'exit' leaves rcon.")
	while True:
		try:
			user_input = input('] ')
			if not user_input:
				continue
			elif user_input == 'exit':
				print('Leaving rcon...')
				break
			elif user_input == 'log':
				sock.sendto(logbuildcommand_to_send(), address)
			else:
				sock.sendto(buildcommand_to_send(user_input, password), address)
				if user_input == 'quit':
					print('Sent server shutdown command; leaving rcon...')
					break

			response = filter_response(sock.recv(BUFFER_SIZE))
			if response:
				print(response)

		except socket.timeout:
			print('Socket timed out; maybe the server is down?')
		except KeyboardInterrupt:
			print('Keyboard interrupt; leaving rcon.')
			break
		except OSError as e:
			print(e)
			sys.exit(1)
		except Exception as e:
			print('There was an unanticipated error:', str(e))
			traceback.print_exc(file=sys.stdout)
			sys.exit(1)

	sock.close()
