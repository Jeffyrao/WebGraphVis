PWD_PATH=$PWD
curl -o db-derby-10.10.1.1-bin.tar.gz http://mirror.sdunix.com/apache//db/derby/db-derby-10.10.1.1/db-derby-10.10.1.1-bin.tar.gz
mkdir /opt/Apache
mv db-derby-10.10.1.1-bin.tar.gz /opt/Apache
cd /opt/Apache/
tar xzf db-derby-10.10.1.1-bin.tar.gz

export DERBY_INSTALL=/opt/Apache/db-derby-10.10.1.1-bin
export CLASSPATH=$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:

cd $PWD_PATH
java -jar $DERBY_INSTALL/lib/derbyrun.jar server start