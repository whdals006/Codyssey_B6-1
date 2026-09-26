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

## 3. 프로젝트 구조

```
B6-1/
├── README.md
├── .gitignore
│
├── website/
│   └── index.html
│
├── scripts/
│   └── setup-nginx.sh
│
└── docs/
    ├── architecture.png
    ├── troubleshooting.md
    ├── cleanup-checklist.md
    └── screenshots/
        └── external-health-check.png
```

## 4. 아키텍처

```
                         Internet
                            │
                            │ HTTP :80
                            ▼
                ┌──────────────────────┐
                │  Internet Gateway    │
                │      B6-1-IGW        │
                └──────────┬───────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │        VPC: B6-1-VPC                │
        │        10.0.0.0/16                  │
        │                                     │
        │  ┌───────────────────────────────┐  │
        │  │ Public Subnet                 │  │
        │  │ 10.0.1.0/24                   │  │
        │  │                               │  │
        │  │    ┌─────────────────────┐    │  │
        │  │    │ EC2                 │    │  │
        │  │    │ B6-1-Web-Server     │    │  │
        │  │    │ Nginx :80           │    │  │
        │  │    └──────────┬──────────┘    │  │
        │  │               │               │  │
        │  │    Security Group             │  │
        │  │    22 → 내 IP/32              │  │
        │  │    80 → 0.0.0.0/0             │  │
        │  └───────────────────────────────┘  │
        │                                     │
        │  Public Route Table                 │
        │  0.0.0.0/0 → B6-1-IGW               │
        └─────────────────────────────────────┘
```

자세한 구조는 docs/architechture.png를 참고.

## 5. 네트워크 구성

* VPC CIDR: 10.0.0.0/16
* Public Subnet CIDR: 10.0.1.0/24
* Route: 0.0.0.0/0 -> Internet Gateway

## 6. Security Group

* Inbound

    | Protocol | Prot | Source | Purpose
    | :--- | :--- | :--- | :--- |
    | TCP | 22 | 개인 IP | SSH |
    | TCP | 80 | 0.0.0.0/0 | HTTP |

* Outbound

    기본 허용 정책을 사용합니다.

## 7. EC2

* Instance Type: micro급
* OS: Ubuntu LTS
* Web Server: Nginx

## 8. 외부 접속 검증

선택 방식:

A. 브라우저로 HTTP 접속

URL:

http://52.79.136.230

또는

B. Health Check

http://52.79.136.230/health

정상 응답:

200 OK

응답 내용:

OK

## 9. 트러블슈팅

자세한 내용은 다음 문서를 참고

docs/troubleshooting.md

## 10. 리소스 정리

자세한 내용은 다음 문서를 참고

docs/cleanup-checklist.md


## 11. IAM 계정 정책

- AmazonEC2FullAccess

- AmazonVPCFullAccess

- IAMReadOnlyAccess

- AWSBillingReadOnlyAccess

