# == Class: postgres_xc::datanode
#
# Initialise datanode node if it was never done (based on $::datanode_directory/postgresql.conf existence)
# Then configure datanode
#
# === Parameters
#
# [*datanode_name*]
#   Name of the node. Has to be different from hostname.
#   Default : ${::hostname}_datanode
#
# [*datanode_hostname*]
#   Hostname of datanode node
#   Default : ${::hostname}
class postgres_xc::datanode

(
$other_database_hostname   = '',
$datanode_name             = "${::hostname}_datanode",
$datanode_hostname         = $::hostname,
)

inherits postgres_xc::params  {

exec { 'initialisation datanode':
  command => "sudo -u ${super_user} initdb --nodename=${datanode_name} -D ${home}/${datanode_directory}",
  unless  => "test -s ${home}/${datanode_directory}/postgresql.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin']
  }->

file { 'datanode postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/postgresql.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/postgresql.conf.erb'),
  }->

file { 'datanode pg_hba.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/pg_hba.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/pg_hba.conf.erb'),
  }->

file { 'datanode_wal_directory':
  ensure    => 'directory',
  path      => "${home}/${other_database_hostname}_arclog",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
}

file { 'datanode recovery.conf':
  ensure    => 'present',
  path      => "${home}/${other_database_hostname}_slave/recovery.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/recovery.conf.erb'),
  require   => Exec['basebackup'],
  }
}
