<?php

require_once __DIR__ . '/../src/SSH.php';

if (!isset($_POST['playload']))
{
    throw new \Exception('No playload found');
}

$data = json_decode($_POST['playload'], true);

/**
 * Getting all references from
 * @url https://api.github.com/repos/:owner/:repo/git/refs
 */
preg_match('#/([a-zA-Z0-9-_]+)/([a-zA-Z0-9-_]+)/([a-zA-Z0-9-_/]+)#', $data['ref'], $matches);
list($refs, $type, $pointer) = $matches;

$ssh = new SSH();
$ssh->connect();
if ($ssh->auth(SSH::AUTH_PASSWORD,['ssh-login', 'ssh-password']))
{
    $commit = $data['after'];
    switch($type)
    {
        case 'heads':
            switch($pointer)
            {
                case 'develop':
                    $ssh->exec('cd /var/www/dev && update.sh ' . $commit);
                    break;
                case 'master':
                    $ssh->exec('cd /var/www/pre-prod && update.sh ' . $commit);
                    break;
                default:
            }
            break;
        case 'tags':
            $ssh->exec('cd /var/www/prod && update.sh ' . $commit);
            break;
    }
}
