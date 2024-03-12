#!/bin/bash

kvm_config=/opt/kvm/km_77_os.xml
kvm_desk=/opt/kvm/km_77_os.qcow2
# 删除所有的kvm虚拟机
del_all_KVM() {
	for i in $(virsh list --all | awk '/vm/{print $2}')
	do
		virsh destroy $i &> /dev/null   # 将虚拟机管理
		virsh undefine $i &> /dev/null  # 删除虚拟机配置文件 
   	done
	rm -rf /var/lib/libvirt/images/*        # 删除虚拟机磁盘文件 
	rm -rf /etc/libvirt/qemu/*             
}

creat_kvm() {
	read -p "请输入要创建几个kvm虚拟机" number
	number_sed=$(virsh list --all | sed '1,2d' | wc -l)    # 判断现在的虚拟机是从几号开始 防止发生覆盖操作
	for i in $(seq $number)				       # 创建几个kvm就循环几次
	do
		setp=$((number_sed + i))                       # 防止覆盖掉前面的配置文件 比如说前面如果有四个虚拟机 则从第五个开始创建
		kvm_name=vm${setp}_centos77
		uuid=$(uuidgen)				       # 随机生成uuid 保证每个kvm的uuid不相同						
		qemu-img create -f qcow2 -b $kvm_desk /var/lib/libvirt/images/${kvm_name}.qcow2 &> /dev/null # 生成后端镜像 类似指针
		cp $kvm_config /etc/libvirt/qemu/${kvm_name}.xml       # copy配置文件
		sed -ri "/kvm_name/ s/kvm_name/${kvm_name}/g" /etc/libvirt/qemu/${kvm_name}.xml
		sed -ri "/mac_number/ s/mac_number/$(openssl rand -hex 10 | sed -r 's/(..)(..)(..)*/\1:\2:\3/')/g" /etc/libvirt/qemu/${kvm_name}.xml
		sed -ri "/kvm_desk_pwd/ s/kvm_desk_pwd/\/var\/lib\/libvirt\/images\/${kvm_name}.qcow2/g" /etc/libvirt/qemu/${kvm_name}.xml
		sed -ri "/uuid_number/ s/uuid_number/${uuid}/g" /etc/libvirt/qemu/${kvm_name}.xml
		virsh define /etc/libvirt/qemu/${kvm_name}.xml &> /dev/null  # 导入kvm
	done
	
}
create_one_kvm() {
	kvm_name=vm$(virsh list --all | sed '1,2d' | wc -l)_centos77
	uuid=$(uuidgen)
        qemu-img create -f qcow2 -b $kvm_desk /var/lib/libvirt/images/${kvm_name}.qcow2 &> /dev/null
        cp $kvm_config /etc/libvirt/qemu/${kvm_name}.xml
        sed -ri "/kvm_name/ s/kvm_name/${kvm_name}/g" /etc/libvirt/qemu/${kvm_name}.xml
        sed -ri "/mac_number/ s/mac_number/$(openssl rand -hex 10 | sed -r 's/(..)(..)(..)*/\1:\2:\3/')/g" /etc/libvirt/qemu/${kvm_name}.xml
        sed -ri "/kvm_desk_pwd/ s/kvm_desk_pwd/\/var\/lib\/libvirt\/images\/${kvm_name}.qcow2/g" /etc/libvirt/qemu/${kvm_name}.xml
        sed -ri "/uuid_number/ s/uuid_number/${uuid}/g" /etc/libvirt/qemu/${kvm_name}.xml
        virsh define /etc/libvirt/qemu/${kvm_name}.xml &> /dev/null
	echo "$kvm_name create successfully"
}
del_one_kvm() {
	read -p "请输入kvm名称" name
	virsh list --all | grep -w "$name"
	if [ $? -eq 0 ]
	then 
		virsh destroy $name &> /dev/null
		virsh undefine $name &> /dev/null
		echo "delete  $name successfully"
	else
		echo "$name is inexistence"
		echo "Please enter the correct name"
	fi
}
show_list_kvm() {
	virsh list --all
}

while true
do
cat <<eof
--------KVM创建虚拟机----------
1、删除所有的KVM虚拟机
2、批量创建KVM虚拟机
3、创建一个KVM虚拟机
4、删除一个KVM虚拟机
5、显示KVM虚拟机列表
6、退出
eof
echo
echo
read -p "你要闹什？" set
case ${set} in
    1)
     del_all_KVM
     echo "delete successfully"
     ;;
    2)
     creat_kvm
     echo "successfully"
     ;;
    3)
     create_one_kvm
     ;;
    4)
     del_one_kvm
     ;;
    5)
     show_list_kvm
     ;;
    6)
     exit
     echo "see you again"
     ;;
esac
done























