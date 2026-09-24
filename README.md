# 내가 만든 웹사이트를 인터넷에 올려 누구나 쓰게 하기

## 1. 프로젝트 개요

AWS VPC와 EC2를 이용해 외부에서 접속 가능한 웹 서비스를 구축하는 미션입니다.

## 2. 사용 환경

- AWS
- Region: ap-northeast-2 (Seoul)
- VPC
- Public Subnet
- Internet Gateway
- EC2
- Nginx

## 3. 아키텍처

```text
Internet
   |
   v
Internet Gateway
   |
   v
VPC
   |
   v
Public Subnet
   |
   v
EC2
   |
   v
Nginx
```

자세한 구조는 docs/architechture.png를 참고.

## 4. 네트워크 구성

* VPC CIDR: 10.0.0.0/16
* Public Subnet CIDR: 10.0.1.0/24
* Route: 0.0.0.0/0 -> Internet Gateway

## 5. Security Group

* Inbound

    | Protocol | Prot | Source | Purpose
    | :--- | :--- | :--- | :--- |
    | TCP | 22 | 개인 IP | SSH |
    | TCP | 80 | 0.0.0.0/0 | HTTP |

* Outbound

    기본 허용 정책을 사용합니다.

## 6. EC2

* Instance Type: micro급
* OS: Ubuntu LTS
* Web Server: Nginx

## 7. 외부 접속 검증

선택 방식:

A. 브라우저로 HTTP 접속

URL:

http://<PUBLIC_IP>

또는

B. Health Check

http://<PUBLIC_IP>/health

정상 응답:

200 OK

응답 내용:

OK

## 7. 트러블슈팅

자세한 내용은 다음 문서를 참고

docs/troubleshooting.md

## 8. 리소스 정리

자세한 내용은 다음 문서를 참고

docs/cleanup-checklist.md

