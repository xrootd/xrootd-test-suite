from XrdTest.ClusterUtils import Cluster, Network, Host, Disk 

def getCluster():
  cluster = Cluster( "cluster_meta_manager")

  #-----------------------------------------------------------------------------
  # Cluster defaults
  # The bootImage parameter is relative to the storage_pool location as given
  # in the hypervisor config file.
  #-----------------------------------------------------------------------------
  cluster.defaultHost.bootImage      = 'slc6_testslave_ref.img'
  cluster.defaultHost.cacheBootImage = True
  cluster.defaultHost.arch           = 'x86_64'
  cluster.defaultHost.ramSize        = '1048576'

  #-----------------------------------------------------------------------------
  # Network definition
  #-----------------------------------------------------------------------------
  net = cluster.network
  net.ip        = '192.168.128.1'
  net.netmask   = '255.255.255.0'
  net.DHCPRange = ('192.168.128.20', '192.168.128.254')

  #-----------------------------------------------------------------------------
  # Host definitions
  #-----------------------------------------------------------------------------
  loadBalance = ["multiip.xrd.test"]

  metaman = Host('metaman.xrd.test', '192.168.128.3',
                 aliases=loadBalance, mac="00:08:30:30:98:31")
  man1    = Host('man1.xrd.test',    '192.168.128.4',
                 aliases=loadBalance, mac="00:08:30:30:98:32")
  man2    = Host('man2.xrd.test',    '192.168.128.5',
                 aliases=loadBalance, mac="00:08:30:30:98:33")
  srv1    = Host('srv1.xrd.test',    '192.168.128.6',
                 aliases=loadBalance, mac="00:08:30:30:98:34")
  srv2    = Host('srv2.xrd.test',    '192.168.128.7',
                 aliases=loadBalance, mac="00:08:30:30:98:35")
  srv3    = Host('srv3.xrd.test',    '192.168.128.8',
                 aliases=loadBalance, mac="00:08:30:30:98:36")
  srv4    = Host('srv4.xrd.test',    '192.168.128.9',
                 aliases=loadBalance, mac="00:08:30:30:98:37")
  client1 = Host('client1.xrd.test', '192.168.128.10',
                 aliases=loadBalance, mac="00:08:30:30:98:38",
                 ramSize = '4194304')

  #-----------------------------------------------------------------------------
  # Additional host disk definitions
  #-----------------------------------------------------------------------------
  srv1.disks    = [Disk('disk1', '20G', device='vda', mountPoint='/data')]
  srv2.disks    = [Disk('disk1', '20G', device='vda', mountPoint='/data')]
  srv3.disks    = [Disk('disk1', '20G', device='vda', mountPoint='/data')]
  srv4.disks    = [Disk('disk1', '20G', device='vda', mountPoint='/data')]
  client1.disks = [Disk('disk1', '20G', device='vda', mountPoint='/data')]

  #-----------------------------------------------------------------------------
  # Add hosts and finish up
  #-----------------------------------------------------------------------------
  hosts = [metaman, man1, man2, srv1, srv2, srv3, srv4, client1]
  cluster.addHosts(hosts)
  return cluster
