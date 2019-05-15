"""Remote Console"""
import sys
import socket
import traceback

PACKING_BYTES = b'\xFF\xFF\xFF\xFF'
BUFFER_SIZE = 10240
SOCKET_TIMEOUT = 4


def usage():
	print('Quake Remote Console (part of AGRIP AudioQuake)')
	print('Usage:', sys.argv[0], '[host [port]]')
	print('   or:', sys.argv[0], '--ask')


def _log_build_command_to_send():
	# leaving out the \n or having \x00 works too
	return _command_core('log\n')


def _build_command_to_send(command, password):
	return _command_core('rcon ' + password + ' ' + command + '\x00')


def _command_core(processed):
	return PACKING_BYTES + bytes(processed, 'ascii')


def _filter_response(received):
	if received.startswith(PACKING_BYTES):
		return received[5:].rstrip().decode()  # an 'n' follows the padding
	else:
		return received.rstrip().decode()


if __name__ == '__main__':
	if len(sys.argv) == 2 and sys.argv[1] == '--ask':
		# Ask user for host and port (used when run from launcher)
		host = input('Server hostname or IP [default: localhost]: ') \
			or 'localhost'
		port = input('Server port [default: 27500]: ') or '27500'
		port = int(port)
	else:
		# Standard command-line use
		if len(sys.argv) < 2:
			usage()
		elif sys.argv[1] == '-h' or sys.argv[1] == '--help':
			usage()
			sys.exit(0)
		host = sys.argv[1] if len(sys.argv) > 1 else 'localhost'
		port = int(sys.argv[2]) if len(sys.argv) > 2 else 27500
	print('Will connect to:', host, port)
	address = (host, port)

	# Ask for password
	password = input('Server rcon password [default: rconpasswd]: ') \
		or 'rconpasswd'

	# Create and bind to socket (but we are not really connecting yet)
	try:
		sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		sock.settimeout(SOCKET_TIMEOUT)
	except Exception as e:
		print('There was an error making the socket:', str(e))
		sys.exit(1)

	# Main loop
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
				sock.sendto(_log_build_command_to_send(), address)
			else:
				sock.sendto(
					_build_command_to_send(user_input, password), address)

			if user_input == 'quit':
				print('Sent server shutdown command; leaving rcon...')
				break
			else:
				response = _filter_response(sock.recv(BUFFER_SIZE))
				if response:
					print(response)
		except socket.timeout:
			print('Socket timed out; maybe the server is down?')
		except KeyboardInterrupt:
			print('Keyboard interrupt; leaving rcon.')
			break
		except Exception as e:
			print('There was an unanticipated error:', str(e))
			traceback.print_exc(file=sys.stdout)
			sys.exit(1)

	sock.close()
