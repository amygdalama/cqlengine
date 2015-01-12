# Basic virtualbox configuration
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

node basenode {
  package{["build-essential", "git-core", "vim"]:
    ensure => installed
  }
}

class xfstools {
    package{['lvm2', 'xfsprogs']:
        ensure => installed
    }
}
class java {
    package {['openjdk-7-jre-headless']:
        ensure => installed 
    }
}

class pgpkeys {
    include apt

    apt::key { 'key1':
        ensure      => present,
        key         => 'F758CE318D77295D',
        key_server  => 'pgp.mit.edu',
    }

    apt::key { 'key2':
        ensure      => present,
        key         => '2B5C1B00',
        key_server  => 'pgp.mit.edu',
    }

    apt::key { 'key3':
        ensure      => present,
        key         => '0353B12C',
        key_server  => 'pgp.mit.edu',
    }
}

class cassandra {
    include apt
    require pgpkeys
    require java
    require xsftools

    apt::source { 'cassandra':
      location          => 'http://www.apache.org/dist/cassandra/debian/',
      release           => '12x',
      repos             => 'main',
      required_packages => 'debian-keyring debian-archive-keyring',
      key               => '4BD736A82B5C1B00',
      key_server        => 'pgp.mit.edu',
      notify            => Package ['cassandra'],

    }

    package { 'cassandra':
      ensure => installed,
    }

}

node cassandraengine inherits basenode {
  include cassandra

  package {["python-pip", "python-dev", "python-nose"]:
    ensure => installed
  }

  exec {"install-requirements":
    cwd => "/vagrant",
    command => "pip install -r requirements-dev.txt",
    require => [Package["python-pip"], Package["python-dev"]]
  }
}
