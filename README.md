# Yet Another Web Scanning Toolchain

docker build -t yawst .

docker run -v $(pwd)/results:/yawst/results -it yawst https://www.hackthissite.org/