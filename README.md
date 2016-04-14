sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev make unzip git redis-server g++ libjansson-dev libpython-dev expat libexpat1-dev

cd $HOME

git clone https://github.com/DATAKTM/datak

cd datak

chmod +x launchfix2.sh

chmod +x launch.sh

./launchfix2.sh install

cd .luarocks

cd bin

./luarocks-5.2 install luafilesystem

./luarocks-5.2 install lub

./luarocks-5.2 install luaexpat

cd $HOME

cd datak

./launchfix2.sh install

./launch.sh

--------------------------------------------------------------------------------------------------------------------------------------
sudo apt-get update

sudo apt-get upgrade

sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev make unzip git redis-server g++ libjansson-dev libpython-dev expat libexpat1-dev

git clone https://github.com/DATAKTM/datak

cd datak

chmod +x launch.sh

./launch.sh install

./launch.sh


