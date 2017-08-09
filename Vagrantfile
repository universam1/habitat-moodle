Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.synced_folder '', '/my'
  config.vm.network :private_network, ip: '192.168.33.10'
  config.vm.network 'forwarded_port', guest: 80, host: 80

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = false
    vb.memory = '1024'
    vb.cpus = 2
  end
  config.vm.provision 'shell', inline: <<-SHELL
    apt-get update
    apt-get install git -y
    adduser --system --group hab
    useradd --system --group hab hab
    curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
    sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64
    sudo chmod +x /usr/local/bin/gitlab-runner
    sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bashsudo apt-get install -y git
    sudo apt-get install -y awscli
    SHELL
end
