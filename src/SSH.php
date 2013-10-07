<?php
/**
 * Class SSH
 */

class SSH
{
    const AUTH_AGENT     = 'agent';
    const AUTH_HOSTBASED = 'hostbased';
    const AUTH_NONE      = 'none';
    const AUTH_PASSWORD  = 'password';
    const AUTH_PUBLIC_KEY= 'public';

    const EXEC_OUTPUT = 0;
    const EXEC_ERROR = 1;

    protected $host;
    protected $port;
    protected $connection;

    protected $outStream;
    protected $errStream;

    public function __construct($host = '127.0.0.1', $port = 22)
    {
        extension_loaded('ssh2') || die('ssh2 not installed');
        $this->host = $host;
        $this->port = $port;
    }

    public function connect()
    {
        $this->connection = ssh2_connect($this->host, $this->port);

        return $this;
    }

    public function auth($type = self::AUTH_PASSWORD, array $options = [])
    {
        $result = false;
        array_unshift($options, $this->connection);
        switch($type)
        {
            case self::AUTH_PASSWORD:
                $result = call_user_func_array('ssh2_auth_password', $options);
                break;

        }
        return $result;
    }

    public function exec($command, $pty = null, array $env = null, $width = null, $height = null, $width_height_type = null)
    {
        $stream = ssh2_exec($this->connection, $command, $pty, $env, $width, $height, $width_height_type);
        $errorStream = ssh2_fetch_stream($stream, SSH2_STREAM_STDERR);

        // Enable blocking for both streams
        stream_set_blocking($errorStream, true);
        stream_set_blocking($stream, true);

        $result = [stream_get_contents($stream), stream_get_contents($errorStream)];

        fclose($errorStream);
        fclose($stream);

        return $result;
    }
}