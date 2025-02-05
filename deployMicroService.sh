cd /home/icicle/icicleEdge
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 30080website
echo Deployed Website!
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 4242phonehub
echo Deployed Phone Hub!  
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 1212aimissions 
echo Deployed AI Mission in the background!
