all: vagrant

vagrant:
	vagrant up --no-destroy-on-error --no-color | tee ./vagrantup.log
	./scripts/vagrant-ips.sh | tee -a ./vagrantup.log
	vagrant rsync | tee -a ./vagrantup.log
	vagrant provision --no-color | tee -a ./vagrantup.log

clean:
	vagrant destroy -f --no-color
	rm -rf .vagrant .k8s-ips *.log
