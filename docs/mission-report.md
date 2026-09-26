# 내가 만든 웹사이트를 인터넷에 올려 누구나 쓰게 하기

## 1. 기본 프로젝트 구조 만들기

### 1-1. 폴더 구조

```
B6-2/
├─ website/
│   └─ index.html
├─ scripts/
│   └─ setup-nginx.sh
├─ docs/
│   ├─ troubleshooting.md
│   └─ cleanup-checklist.md
├─ .gitignore
└─ REAMDE.md
```

## 2. VPC 네트워크 구성

 : 외부 인터넷과 EC2가 통신할 수 있는 네트워크 기반을 만드는 단계

### 2-1. AWS region 확인

```
Asia Pacific (seoul)
ap-northeast-2
```

### 2-2. VPC 생성

```
name : B6-1-VPC
IPv4 CIDR : 10.0.0.0/16
IPv6 CIDR : 없음
Tenancy : Default
```

### 2-3. Subnet 생성

```
name : B6-1-Public-Subnet
가용 영역 : 아시아 태평양 (서울) / apne2-az1 (ap-northeast-2a)
IPv4 VPC CIDR 블록 : 10.0.0.0/16
IPv4 Subnet CIDR 블록 : 10.0.1.0/24

(Subnet 생성 후 필수 설정)
퍼블릭 IPv4 주소 자동 할당 : 예
```

* VPC를 Subnet으로 나누는 이유

    - 보안 영역 분리하기 위해서

        - Public Subnet : IGW와 연결되어 외부 인터넷 사용자들이 접근할 수 있는 영역 (웹 서버)
        - Private Subnet : 외부 인터넷과 단절된 영역 (데이터베이스)

    - 물리적 다중화를 위해서

        - AWS 데이터 센터 하나에 불이 나거나 정전이 되어도 서비스가 중단되지 않도록, 물리적으로 떨어진 서로 다른 데이터 센터에 서브넷을 각각 하나씩 배치하기 위해서
        - 하나의 서브넷은 하나의 가용 영역(AZ)에만 귀속된다.

* 퍼블릭 IPv4 주소 자동 할당 활성화

    - 서브넷 내에 생성되는 서버(EC2)에 인터넷 접속용 외부 IP(퍼블릭 IP)를 자동으로 쥐어주는 설정

### 2-4. IGW 생성 및 연결

```
name : B6-1-IGW
```

* IGW를 VPC에 연결

### 2-5. Route Table 설정

1. Routing Table 생성

    ```
    name : B6-1-Public-RT
    VPC : B6-1-VPC
    ```

2. IGW 길안내 추가

    * Routing Table 편집

    ```
    Destination : 0.0.0.0/0
    Target : B6-1-IGW
    ```

    의미 : VPC 내부에서 목적지가 VPC 내부 경로로 명확하게 지정되지 않은 IPv4 트래픽은 IGW로 보낸다.

3. Subnet 과 Route Table 연결

    * Subnet 연결 탭 → 서브넷 연결 편집

    ```
    B6-1-Public-Subnet 과 연결
    ```


## 3. Security Group 설계

### 3-1. 현재 사용 중인 Public IPv4 확인하기

```bash
curl -4 https://checkip.amazonaws.com
```

```bash
curl -4 https://ifconfig.me
```

### 3-2. 인바운드 규칙 추가

1. SSH 인바운드 규칙

    ```
    Type: SSH
    Protocol: TCP
    Port: 22
    Source Type: My IP
    Source: X.X.X.X/32
    ```

2. HTTP 인바운드 규칙

    ```
    Type: HTTP
    Protocol: TCP
    Port: 80
    Source Type: Anywhere-IPv4
    Source: 0.0.0.0/0
    ```

### 3-3. 아웃바운드 규칙

디폴트로 있는 규칙만 사용 (모든 outbound 트래픽 허용 규칙)


## 4. EC2 인스턴스 생성

### 4-1. 인스턴스 생성

```
name: B6-1-Web-Server
application & OS image: Ubuntu Server 26.04 LTS (64bit)
instance type: t3.micro
key pair: B6-1-key
```

* 키페어 생성

```bash
name: B6-1-key
Type: RSA
키파일 형식: .pem

# 안전을 위해 ~/.ssh 에 보관
```

* 키의 권한 변경

```bash
chmod 400 B6-1-key.pem

# 결과 : -r--------  1 jongmin006 jongmin006 1678 Sep 25 16:08 B6-1-key.pem
```

* 네트워크 설정

```
VPC: B6-1-VPC
Subnet: B6-1-Public-Subnet
Public IP 자동 할당: 활성화
Security Group: B6-1-Web-SG
```

* 스토리지 구성

```
8 Gib gp3
```

## 5. SSH 접속

### 5-1. 기본적인 테스트

```bash
ssh -i ~/.ssh/B6-1-key.pem ubuntu@Public_IP

# 접속에 성공하면 ubuntu@ip-10-0-1-10:~$ 처럼 변한다.
```

* ubuntu 버전 확인

```bash
cat /etc/os-release
```

* 아키텍처 확인

```bash
uname -m
```

* 인터넷 아웃바운드 통신 확인

```bash
curl -I https://example.com
```

### 5-2. Nginx 설치

* 시스템 패키지 목록 업데이트

```bash
sudo apt update
```

* Nginx 설치

```bash
sudo apt install -y nginx
```

* Nginx 실행 상태 확인

```bash
sudo systemctl status nginx

# 화면 빠져나오려면 q 누른다.
```

* Nginx 부팅 자동 실행 확인

```bash
sudo systemctl is-enabled nginx

# 결과가 enabled 이면 EC2가 재부팅돼도 Nginx가 자동으로 시작한다.
```

* 로컬 HTTP 접속 확인

```bash
curl -I httpL//localhost

# 정상적으로 동작한다면 HTTP/1.1 200 OK 가 뜬다
```

### 5-3. SSH 접속에 빠져나오기

```bash
exit
```

## 6. SSH로 EC2 내부에 웹 서버 배포하기

### 6-1. index.html 파일을 EC2 내부의 tmp 폴더로 복사

```bash
scp -i ~/.ssh/B6-1-key.pem website/index.html ubuntu@52.79.136.230:/tmp/index.html
```

```bash
scp [옵션] [pair_key 경로] [보낼_원본_파일_경로] [원격서버_계정]@[원격서버_Public_IP]:[저장할_목적지_경로]
```

1. `scp` (Secure Copy Protocol)
    - SSH(Secure Shell) 네트워크 프로토콜을 기반으로 파일이나 디렉토리를 암호화하여 안전하게 전송하는 CLI 명령어

2. `-i` (Identity File)
    - SSH/SCP 접속 시 나를 인증할 비밀키 파일의 경로를 지정하겠다는 옵션

3. `옮길 원본 파일`
    - 내 컴퓨터에서 EC2로 전송하고자 하는 파일의 현재 위치

4. `[계정명]@[서버IP]:[원격경로]`
    - 원본 파일을 전송할 목적지

### 6-2. tmp 폴더에서 var/www 폴더로 복사

```bash
sudo mkdir -p /var/www/cloud-portfolio
```

```bash
sudo cp /tmp/index.html /var/www/cloud-portfolio/index.html
```

### 6-3. Nginx server block 생성

* Nginx 웹서버의 '사이트 설정 파일' 생성

    ```bash
    sudo nano /etc/nginx/sites-available/cloud-portfolio

    # cloud-portfolio 라는 이름의 웹사이트 설정 문서가 생성된다.
    ```

    - `/etc/nginx/` : Nginx 웹 서버와 관련된 제어 파일들이 저장된 표준 위치

    - `sites-available` : Nginx 에서 만들 수 있는 여러 웹사이트의 설정 파일을 보관해 두는 창고

    - `cloud-portfolio` : 웹사이트 설정 파일의 이름

* 작성 내용

```bash
server {
    listen 80;          # IPv4 에서 80번 포트로 오는 요청을 감지
    listen [::]:80;     # IPv6 에서 80번 포트로 오는 요청을 감지

    server_name _;      # 이 서버로 들어오는 모든 도메인/IP 요청을 처리

    root /var/www/cloud-portfolio;      # 실제 웹 파일들이 저장되어 있는 EC2 내부 경로
    index index.html;       # 사용자가 디렉토리 경로만 접속했을 때 기본으로 불러온 대표 파일명

    # 기본 루트 요청(/)
    location / {
        try_files $uri $uri/ =404;
    }

    # 헬스 체크 요청(/health)
    location = /health {
        default_type text/plain;
        return 200 "OK\n";
    }
}
```

### 6-4. 기존에 default로 있는 Nginx 사이트 삭제

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

### 6-5. 내가 만든 사이트 활성화

* 심볼릭 링크 만들기

    ```bash
    sudo ln -sf \
        /etc/nginx/sites-available/cloud-portfolio \
        /etc/nginx/sites-enabled/cloud-portfolio
    ```

    ```bash
    sudo ln [옵선] [원본_파일_경로] [바로가기_생성할_경로]
    ```

    - `ln` (Link) : 파일이나 디렉토리에 대한 링크를 만드는 명령어

    - `-s` (--symbolic) : 소프트 링크를 생성하는 옵션 (바탕화면 바로가 아이콘과 동일한 개념)

    - `-f` (--force) : 강제 옵션

* Nginx 설정 문법 검사

```bash
sudo nginx -t

# syntax is ok
# test is sucesfful
# 위 문구가 나오면 정상
```

* Nginx 재시작

```bash
sudo systemctl restart nginx
```

### 6-6. 내가 만든 웹페이지 확인

```bash
curl http://localhost
```

또는

```
(주소창에) http://EC2_Public_IP
```

### 6-7. /health 확인

EC2 내부에서

```bash
curl -i http://localhost/health
```

결과:

```
HTTP/1.1 200 OK
Server: nginx/1.28.3 (Ubuntu)
Date: Fri, 25 Sep 2026 12:40:52 GMT
Content-Type: text/plain
Content-Length: 3
Connection: keep-alive

OK
```

### 6-8. 80번 포트 열려있는지 확인

```bash
sudo ss -tlnp | grep :80
```

결과:

```
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2580,fd=5),("nginx",pid=2579,fd=5),("nginx",pid=2578,fd=5))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=2580,fd=6),("nginx",pid=2579,fd=6),("nginx",pid=2578,fd=6))
```

