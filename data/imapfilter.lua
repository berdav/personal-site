--[[ Configuration file for automated filters ]]
-- *** Helpers *** --
function read_password ( account )
	local command = "gpg2 "
	command = command .. "-dq "
	command = command .. "--batch "
	command = command .. "--pinentry-mode loopback "
	command = command .. "--no-tty "
	command = command .. "--for-your-eyes-only "
	command = command .. "--passphrase-file /home/user/.passwords/passphrase "
	command = command .. "/home/user/.passwords/"
	command = command .. account .. ".gpg"
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()

	result = string.gsub(result, "\n*$", '')

	return result
end

-- *** Global options *** --
-- Create the directory on the server side
options.create       = true
options.certificates = true
options.starttls     = true
options.close        = true
options.timeout      = 60

-- *** Gmail filter *** --
gmail = IMAP {
	server       = 'imap.gmail.com',
	username     = 'redacted@gmail.com',
	password     = read_password('redacted@gmail.com'),
	ssl          = 'auto'
}
gmail_last_seen      = gmail["INBOX"]:is_newer(30)

social_network       = gmail_last_seen
social_network       = social_network:contain_from("social@network.com")
social_network:move_messages(gmail["Social"])
