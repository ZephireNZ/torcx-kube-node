k8s_version = 1.27.1
helm_version = 3.11.3

build: clean dirs torcx.tgz torcx.squashfs

clean:
	rm -rf build/
	rm -rf dist/

dirs:
	mkdir -p build/
	mkdir -p dist/

kube-node.tar.gz:
	wget -q https://dl.k8s.io/v$(k8s_version)/kubernetes-node-linux-amd64.tar.gz -O build/kube-node.tar.gz

kube-node: kube-node.tar.gz
	cd build && tar -xzf kube-node.tar.gz


helm.tar.gz:
	wget -q https://get.helm.sh/helm-v$(helm_version)-linux-amd64.tar.gz -O build/helm.tar.gz

helm: helm.tar.gz
	cd build && tar -xzf helm.tar.gz


torcx: kube-node helm
	cp -ar rootfs dist/
	mkdir -p dist/rootfs/bin
	cp -ar build/kubernetes/node/bin/* dist/rootfs/bin/
	cp -a build/linux-amd64/helm dist/rootfs/bin/
	

torcx.tgz: torcx
	cd dist && tar -C rootfs -czf kube-node.torcx.tgz .

torcx.squashfs: torcx
	cd dist && mksquashfs rootfs kube-node.torcx.squashfs -comp gzip
