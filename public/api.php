<?php

require_once __DIR__ . '/../src/SSH.php';

if (!isset($_POST['playload']))
{
    throw new \Exception('No playload found');
}

function loginAndExecute($login, $password, $command)
{
    $ssh = new SSH();
    $ssh->connect();
    if ($ssh->auth(SSH::AUTH_PASSWORD,[$login, $password]))
    {
        $ssh->exec($command);
        return true;
    }
    return false;
}



$data = json_decode($_POST['playload'], true);

/**
 * Getting all references from
 * @url https://api.github.com/repos/:owner/:repo/git/refs
 */
preg_match('#/([a-zA-Z0-9-_]+)/([a-zA-Z0-9-_]+)/([a-zA-Z0-9-_/]+)#', $data['ref'], $matches);
list($refs, $type, $pointer) = $matches;
$commit = $data['after'];
switch($type)
{
    case 'heads':
        switch($pointer)
        {
            case 'develop':
                loginAndExecute('dev-login', 'dev-password', 'cd /var/www/dev && update.sh');
                break;
            case 'master':
                loginAndExecute('pre-prod-login', 'pre-prod-password', 'cd /var/www/pre-prod && update.sh');
                break;
            default:
        }
        break;
    case 'tags':
        loginAndExecute('prod-login', 'prod-password', 'cd /var/www/prod && update.sh');
        break;
}