# Troubleshooting Report

## 문제 1. 외부 HTTP 접속 실패

### 1. 증상

EC2 내부에서는 `/health` 요청이 정상적으로 처리되었지만,
외부 환경에서 Public IP를 이용해 `/health`에 접속했을 때
HTTP 요청이 정상적으로 완료되지 않았다.

EC2 내부 테스트:

```bash
curl -i http://localhost/health
```

결과:

```
HTTP/1.1 200 OK

OK
```

외부 테스트:

```bash
curl -i --connect-timeout 5 http://52.79.136.230/health
```

결과:

```
curl: (28) Failed to connect to 52.79.136.230 port 80 after 5002 ms: Timeout was reached
```

### 2. 원인 가설

다음 항목 중 하나가 원인일 수 있다고 가설을 세웠다.

1. Nginx가 중지되었다.
2. EC2가 80번 포트에서 listening 하지 않는다.
3. Security Group에서 TCP 80이 허용되지 않는다.
4. Public Subnet의 Route Table에 Internet Gateway 경로가 없다.

### 3. 검증

1. Nginx 상태 확인

    EC2에서:

    ```bash
    sudo systemctl status nginx
    ```

    결과:

    ```
    Active: active (running)
    ```

2. 80번 포트 listening

    ```bash
    sudo ss -tlnp | grep :80
    ```

    결과:

    ```
    LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2580,fd=5),("nginx",pid=2579,fd=5),("nginx",pid=2578,fd=5))
    LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=2580,fd=6),("nginx",pid=2579,fd=6),("nginx",pid=2578,fd=6))
    ```

3. Security Greoup 확인

    aws 의 EC2 에서 Security Group 을 확인

    결과:

    인바운드 규칙에 SSH 22포트만 있고, HTTP의 80번 포트가 없다.

### 4. 조치

Security Group 에 인바운드 규칙을 추가한다

```
Type: HTTP
Protocol: TCP
Port: 80
Source: 0.0.0.0/0
```

### 5. 결과

외부에서 다음 주소로 접속하여 정상 응답을 확인한다.

http://52.79.136.230/health

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

