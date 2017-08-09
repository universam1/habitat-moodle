<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
{{#if bind.database.first.cfg.ipaddress}}
$CFG->dbhost    = '{{bind.database.first.cfg.ipaddress}}';
{{/if}}
{{#unless bind.database.first.cfg.ipaddress}}
$CFG->dbhost    =  '{{bind.database.first.sys.ip}}';
{{/unless}}
$CFG->dbname    = '{{cfg.dbname}}';
$CFG->dbuser    = '{{bind.database.first.cfg.username}}';
$CFG->dbpass    = '{{bind.database.first.cfg.password}}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => {{bind.database.first.cfg.port}},
  'dbsocket' => 'false',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = '{{cfg.wwwroot}}';
$CFG->dataroot  = '/hab/svc/moodle/data/dataroot';
$CFG->admin     = '{{cfg.adminuser}}';

$CFG->directorypermissions = 02777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// // it is intentional because it prevents trailing whitespace problems!
