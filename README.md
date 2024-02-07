[![Create Release](https://github.com/kalibrado/servarr-dashboard/actions/workflows/tags-docker-image.yml/badge.svg?branch=main&event=deployment)](https://github.com/kalibrado/servarr-dashboard/actions/workflows/tags-docker-image.yml)

TODO
Add WebApp SQLBrowser for backups

![image](https://github.com/kalibrado/servarr-dashbrod/assets/51781584/8e0fdba6-0b0a-47c3-b552-73737fa4361e)

![image](https://github.com/kalibrado/servarr-dashbrod/assets/51781584/3b3a6eb3-a0ad-4972-9b51-09ae1e013693)

git clone https://github.com/kalibrado/servarr-dashboard.git

cd servarr-dashboard

docker build -t servarr .

docker run  --name=servarr -p 80:80  servarr
