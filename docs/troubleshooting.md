# Troubleshooting Report

## 문제 1. EC2 외부 HTTP 접속 실패

### 1. 증상

EC2의 웹 서버가 실행 중임에도 외부 PC의 브라우저에서
`http://<PUBLIC_IP>` 접속이 되지 않았다.

### 2. 원인 가설

다음 항목 중 하나가 원인일 수 있다고 가설을 세웠다.

1. Security Group에서 TCP 80이 허용되지 않음
2. Public Subnet의 Route Table에 Internet Gateway 경로가 없음
3. EC2에 Public IPv4가 없음
4. Nginx가 실행되고 있지 않음

### 3. 검증

다음 명령 및 AWS 콘솔 설정을 확인한다.

```bash
curl -I http://localhost
```
```bash
sudo systemctl status nginx
```

그리고 AWS 콘솔에서 다음 항목을 확인한다.

* Security Group inbound rule
* EC2 Public IPv4
* Route Table
* Internet Gateway 연결

### 4. 조치

실제 발생한 원인에 따라 필요한 설정을 수정한다.

### 5. 결과

외부에서 다음 주소로 접속하여 정상 응답을 확인한다.

http://<PUBLIC_IP>/health

결과:

200 OK

응답:

OK

### 6. 재발 방지

다음 배포부터 다음 항목을 체크한다.

* Public IPv4 확인
* Route Table의 0.0.0.0/0 확인
* Internet Gateway 연결 확인
* Security Group TCP 80 확인
* Nginx 상태 확인

