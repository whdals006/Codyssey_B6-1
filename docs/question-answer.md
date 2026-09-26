## 7. 보안 그룹(Security Group) 인바운드 정책 및 설정 근거

본 서비스는 최소 권한(Least Privilege) 및 최소 노출(Minimal Exposure) 원칙에 따라, **서비스 사용자**와 **운영자(관리자)**의 역할을 명확히 분리하여 인바운드 포트 및 IP 범위를 제어합니다.

### 1. 포트별 허용 / 차단 결정 기준

| 구분 | 포트(Port) | 소스(Source) | 결정 근거 및 보안 정책 |
| :--- | :--- | :--- | :--- |
| **HTTP (웹 서비스)** | `80` (TCP) | `0.0.0.0/0` (Anywhere) | **[서비스 용도]** 불특정 다수의 일반 사용자가 웹 사이트에 접속해야 하므로 전 세계 모든 IP 대역에 대해 접근을 허용합니다. |
| **SSH (원격 관리)** | `22` (TCP) | `My IP` (단일 IP/32) | **[운영자 용도]** 인스턴스 제어 및 관리 목적으로, 외부 무단 접근 및 Brute Force(무차별 대입) 공격을 차단하기 위해 **실제 관리자의 작업 IP로만 제한**합니다. |
| **기타 모든 포트** | `0 - 65535` | `Deny` (기본 차단) | **[최소 포트 원칙]** 서비스 및 운영에 필요한 80, 22번 이외의 모든 포트(예: DB, FTP 등)는 인바운드를 차단하여 공격 표면(Attack Surface)을 최소화합니다. |

### 2. 보안 정책 적용 이유 (Inbound Rule Policy)
1. **역할 기반 접근 제어 (RBAC)**
   - **사용자(Traffic Source: Public):** 웹 서비스 응답에 필요한 80 포트 외의 시스템 내부 영역이나 관리 포트에 접근할 수 없도록 제한합니다.
   - **운영자(Traffic Source: Trusted IP):** 인프라 관리 권한이 있는 특정 IP 환경에서만 22 포트를 통해 원격 제어가 가능하도록 제한합니다.

2. **보안 사고 예방 (Default Deny / Implicit Deny)**
   - AWS 보안 그룹 특성상 **"명시적으로 허용(Allow)되지 않은 모든 트래픽은 기본 차단(Implicit Deny)"**됩니다.
   - `0.0.0.0/0` 전체 포트 오픈(0-65535) 시, 열려있는 다른 포트를 통한 시스템 침입, 리소스 악용(크립토재킹 등) 및 데이터 유출 위험이 발생하므로 필요한 최소한의 포트만 핀포인트로 오픈했습니다.


## 9. 리소스 식별 및 관리 정책 (Naming & Tagging Policy)

복수의 리소스 관리 및 비용 추적, 운영 편의성을 위해 명확한 **네이밍 컨벤션**과 **태그 규칙(Tagging Policy)**을 정립하여 모든 AWS 리소스(VPC, Subnet, IGW, Route Table, EC2, SG 등)에 일관되게 적용했습니다.

### 1. 리소스 네이밍 규칙 (Naming Convention)

* **식별자 형식:** `{Project}-{Environment}-{Resource_Type}`
* **규칙 설명:**
  - `Project`: 프로젝트/서비스 식별자 (예: `web-app`)
  - `Environment`: 배포 환경 (`dev`, `stage`, `prod` 중 구분)
  - `Resource_Type`: 리소스 유형 단축어 (`vpc`, `pub-sub`, `igw`, `rt`, `ec2`, `sg`)

**[적용 예시]**
- **VPC:** `web-app-dev-vpc`
- **Public Subnet:** `web-app-dev-pub-sub`
- **Internet Gateway:** `web-app-dev-igw`
- **Route Table:** `web-app-dev-pub-rt`
- **Security Group:** `web-app-dev-web-sg`
- **EC2 Instance:** `web-app-dev-ec2`

---

### 2. 태그 정책 (Tagging Policy)

AWS 리소스 생성 시 아래 3가지 표준 태그 키(Tag Keys)를 필수 항목으로 부과하여 운영 책임 소재Clarification 및 비용 관리 체계를 구축합니다.

| Tag Key | Tag Value (예시) | 설명 / 설정 이유 |
| :--- | :--- | :--- |
| **`Project`** | `web-app` | 해당 리소스가 속한 프로젝트명 (프로젝트 단위 과금/자원 추적) |
| **`Env`** | `dev` | 자원이 배포된 환경 (`dev`, `stage`, `prod` 구분) |
| **`Owner`** | `JONGMIN` | 리소스 생성자 및 담당자 이름/이메일 (운영 문의 및 보안 책임 소재 명확화) |

> **태그 적용 효과**
> 1. **비용 추적(Cost Allocation):** AWS Billing Console에서 `Project` 및 `Env` 태그별로 발생한 비용을 필터링 및 추적할 수 있습니다.
> 2. **운영 안전성:** `Owner` 태그를 통해 미사용/방치된 자원의 담당자를 즉시 식별하여 불필요한 과금을 방지하고 안전하게 정리할 수 있습니다.


## 11. 보안 및 접근 제어 정책 (Security Group vs IAM & 최소 권한 설계)

본 서비스 인프라는 **네트워크 레이어 보안**과 **AWS API 접근 권한 보안**을 명확히 분리하고, 최소 권한 원칙(Principle of Least Privilege)을 적용하여 보안 경계를 구축했습니다.

---

### 1. Security Group vs IAM 역할 차이

| 구분 | 보안 그룹 (Security Group) | IAM (Identity and Access Management) |
| :--- | :--- | :--- |
| **제어 대상** | **네트워크 트래픽 (Traffic/Packet)** | **AWS 리소스 API 호출 및 행위 (API Actions)** |
| **작동 위치** | EC2 인스턴스의 가상 방화벽 (L3/L4 레이어) | AWS Control Plane / API Gateway 레이어 |
| **주요 역할** | 특정 IP/포트로 들어오고 나가는 IP 패킷 허용/차단 | 특정 사용자(User/Role)가 AWS 리소스를 생성·수정·삭제할 수 있는지 제어 |
| **설정 예시** | "80 포트는 Anywhere, 22 포트는 내 IP만 허용" | "이 IAM 유저는 EC2 생성/조회 권한만 갖고, S3/RDS 접근은 불가" |

---

### 2. IAM 최소 권한(Least Privilege) 설계 방침

광범위한 관리자 권한(`AdministratorAccess`)이나 과도한 서비스 전한(`PowerUserAccess`, `AmazonEC2FullAccess`)을 부여할 경우, 계정 탈취 시 전체 인프라가 위험에 노출됩니다. 

따라서 이번 웹 서비스 구축 미션 수행에 **실제 필요했던 최소한의 Action 목록만 명시한 커스텀 IAM 정책(Custom Policy)**을 구성하여 적용합니다.

#### 🎯 필수 허용 API Action 목록 (최소 권한 범위)
* **VPC & 네트워크**: VPC, Subnet, Internet Gateway, Route Table, Security Group 생성/조회/연결/태그/삭제
* **EC2 컴퓨트**: EC2 인스턴스, Key Pair, Security Group 조회/생성/시작/종료/태그
* **제한 사항 (Explicitly Omitted)**: S3, RDS, DynamoDB, IAM 사용자 생성 등 미션과 무관한 모든 서비스 접근 불허

---

### 3. 최소 권한 IAM Custom Policy (JSON)

아래 JSON 정책을 IAM Policy로 생성하여 실습용 IAM User/Role에 연결합니다.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowVPCNetworkOperations",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DescribeVpcs",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:DeleteSubnet",
        "ec2:CreateInternetGateway",
        "ec2:DescribeInternetGateways",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:CreateRouteTable",
        "ec2:DescribeRouteTables",
        "ec2:CreateRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:DeleteRouteTable"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowEC2AndSecurityGroupOperations",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSecurityGroup",
        "ec2:DescribeSecurityGroups",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:RunInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:CreateKeyPair",
        "ec2:DescribeKeyPairs",
        "ec2:DeleteKeyPair",
        "ec2:CreateTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}
```

## 12. `0.0.0.0/0` 포트 개방의 보안 위험성 및 강화 대안

### 1. `0.0.0.0/0` (전세계 전체 개방) 설정의 보안 위험성

인바운드 규칙에서 소스를 `0.0.0.0/0`으로 지정하는 것은 전 세계 모든 IP의 접근을 허용함을 의미합니다.

* **운영/관리 포트(SSH 22, RDP 3389) 개방 시 위험:**
  - **무차별 대입(Brute Force) 및 딕셔너리 공격:** 자동화된 봇(Bot)과 해커가 22번 포트를 지속적으로 스캐닝하여 패스워드나 Key를 탈취하려는 시도가 실시간으로 발생합니다.
  - **제어권 탈취 및 악용:** 관리자 권한이 탈취될 경우 서버 내 데이터 유출, 랜섬웨어 감염, 크립토제킹(가상화폐 채굴 악용) 등 중대한 보안 사고로 이어집니다.
* **서비스 포트(HTTP 80, HTTPS 443) 개방 시 위험:**
  - 웹 애플리케이션의 취약점(SQL Injection, XSS 등)을 노린 L7 대역 공격 및 DDoS(디도스) 공격 표면(Attack Surface)이 전 세계로 노출됩니다.

---

### 2. 보안 강화를 위한 현실적 대안 및 아키텍처 추천

실무 운영 환경에서는 최소 노출 원칙을 준수하기 위해 아래 대안 중 상황에 맞는 방식을 채택하여 보안을 강화합니다.

| 분류 | 보완 대안 | 작동 방식 및 적용 효과 |
| :--- | :--- | :--- |
| **운영 포트 (SSH/22)** | **① 허용 IP 제한 (My IP / CIDR)** | 관리자의 고정 IP 또는 회사 내부 IP 대역만 핀포인트로 허용하여 인바운드 차단 |
| **운영 포트 (SSH/22)** | **② Bastion Host + VPN** | VPC 내부로 진입하는 전용 길목(Bastion Host)을 두고, VPN 인증을 거친 인가된 사용자만 내부 네트워크 접근 허용 |
| **운영 포트 (SSH/22)** | **③ AWS Systems Manager (SSM) Session Manager** | **[추천]** EC2의 22번 SSH 포트를 아예 열지 않고(`Inbound 0개`), AWS IAM 권한 기반으로 웹 콘솔/CLI를 통해 안전하게 인스턴스 접속 |
| **서비스 포트 (HTTP/80)** | **④ ALB + AWS WAF (Web Application Firewall)** | **[추천]** EC2를 Private Subnet에 숨기고, 앞단에 Application Load Balancer(ALB)와 WAF를 배치. 악성 L7 웹 공격(SQLi, XSS, 봇) 및 DDOS 트래픽을 WAF에서 사전 차단 |

> **💡 추천 보완책:**
> - **운영 접속 대안:** 22번 SSH 포트를 외부에 열지 않고, **AWS SSM Session Manager**를 도입하여 22번 포트 인바운드 규칙 자체를 제거하는 방식을 권장합니다.
> - **웹 서비스 대안:** 단일 EC2 직접 노출 대신 **ALB + AWS WAF 조합**을 연동하여 웹 애플리케이션 보안 공격을 필터링하고 백엔드 인스턴스를 보호하는 아키텍처를 추천합니다.


## 14. 외부 접속 장애 원인 분석 및 점검 5단계 순서

1. EC2 인스턴스에 Public IP가 할당되어 있는지 확인

2. VPC 네트워크 & 라우팅 테이블 점검

    - VPC에 IGW가 정상적으로 Attach되어 있는지 확인
    - EC2가 배치된 Subnet이 Public Subnet인지 확인
    - Public Subnet의 라우팅 테이블에 0.0.0.0/0 (모든 인터넷 트래픽) Destination이 igw-xxxxxxx로 향하도록 설정되어 있는지 확인

3. 보안 그룹(Security Group) 인바운드 규칙 점검

    - Port 80 (HTTP) / Port 443 (HTTPS): 인바운드 규칙에 소스 0.0.0.0/0으로 허용되어 있는지 확인
    - Port 22 (SSH): 관리용 SSH 접속 장애 시, 본인의 현재 공인 IP가 인바운드 규칙 소스에 맞게 등록되어 있는지 확인

4. 웹 서버가 80번 포트에서 요청을 대기 중인지 확인

5. Linux 자체 방화벽에서 80/22 포트를 차단하고 있지 않은지 확인


## 15. IAM 최소 권한(Least Privilege) 설계 및 권한 관리 프로세스

본 인프라 운영 환경에서는 보안 사고 피해 범위를 최소화하기 위해 **"기본 거부(Default Deny)"** 정책을 기본으로 하며, 업무 및 서비스 단위로 최소한의 API 권한만 부여하고 필요한 경우 **승인 및 감사 절차**를 거쳐 권한을 점진적으로 확장합니다.

---

### 1. 서비스/역할별 최소 권한 리스트 (Policy Boundary)

권한 남용 및 무단 변경을 막기 위해 담당 역할 및 서비스 기능에 맞춰 정책을 세분화하여 부여합니다.

| 구분 / 역할 | 필수 허용 API 권한 (Allow Actions) | 제한/차단 권한 (Explicitly Omitted/Denied) |
| :--- | :--- | :--- |
| **네트워크 관리자**<br/>`(VPC Admin)` | `ec2:*Vpc*`, `ec2:*Subnet*`, `ec2:*InternetGateway*`, `ec2:*RouteTable*`, `ec2:*SecurityGroup*` | EC2 인스턴스 생성/삭제, S3, RDS, IAM 권한 변경 불허 |
| **웹 서비스 서버**<br/>`(EC2 Instance Role)` | `s3:GetObject`, `s3:PutObject` (지정된 특정 Bucket만) | EC2/VPC 제어, IAM 정책 수정, 타 AWS 서비스 접근 불허 |
| **개발자/운영자**<br/>`(Developer)` | `ec2:Describe*`, `ec2:StartInstances`, `ec2:StopInstances` | VPC/Subnet 삭제 (`DeleteVpc`), IAM 사용자/정책 변경 불허 |
| **공통 금지 사항** | - | **`AdministratorAccess` 및 `iam:*` (권한 상승 가능 Action) 전체 금지** |

---

### 2. 권한 점진적 확장 절차 (Access Request & Grant Lifecycle)

초기 배포 시에는 **최소 조회/실행 권한**으로 시작하며, 신규 서비스 도입(예: S3, RDS 연동) 등으로 추가 권한이 필요할 경우 아래 **4단계 승인 및 변경 절차**를 준수합니다.

1. **1단계: 권한 요청 (Access Request)**
   * 요청자는 업무 목적, 필요한 **AWS API Action(액션)**, 대상 **Resource ARN**, **필요 기간**을 명시하여 신청합니다.
   * *예시: "S3 로그 저장 목적으로 `s3:PutObject` 권한을 `arn:aws:s3:::my-app-logs/*` 버킷에 한해 요청"*

2. **2단계: 검토 및 승인 (Security Review)**
   * 보안 담당자는 요청된 Action이 와일드카드(`*`)로 과도하게 지정되지 않았는지, 제한된 Resource ARN으로 핀포인트 지정되었는지 검토 후 승인합니다.

3. **3단계: IAM Policy 적용 (Granular Grant)**
   * 와일드카드(`*`) 사용을 금지하고, Inline Policy 또는 Custom Managed Policy 형태로 **최소 범위만 추가**합니다.
   * 임시 작업인 경우 `Condition` 절을 활용하여 **만료 시간(Expiration Time) 또는 IP 제한**을 설정합니다.

4. **4단계: 감사 로그 및 미사용 권한 회수 (Audit & Least Privilege Enforcer)**
   * **AWS CloudTrail 로그 감시:** 권한 부여 후 **CloudTrail**을 통해 실제 호출된 API 항목을 모니터링합니다.
   * **IAM Access Analyzer 활용:** 부여된 권한 중 최근 90일간 사용되지 않은 미사용 권한(Unused Permissions)을 주기로 조회하여 자동 회수/축소 조치합니다.


## 16. 운영 모니터링, 확장(Scaling) 및 비용 추적 전략

단일 EC2 인스턴스 기반 환경에서 발생할 수 있는 병목 현상을 사전에 감지하고, 트래픽 증가에 유연하게 대응함과 동시에 예기치 못한 과금을 방지하기 위한 운영 관리 전략을 정립했습니다.

---

### 1. 성능 병목 감지 지표 (CloudWatch Metrics)

Amazon CloudWatch를 통해 아래 4가지 핵심 인프라 지표를 수집·모니터링하여 서버 병목 및 장애 징후를 감지합니다.

| 모니터링 대상 | 핵심 감지 지표 (Metric) | 임계치 (Threshold) 및 대응 기준 |
| :--- | :--- | :--- |
| **CPU 사용량** | `CPUUtilization` | **70% 이상 5분 지속 시:** 스케일업(Scale-up) 또는 스케일아웃(Scale-out) 검토 |
| **메모리 / Swap** | `mem_used_percent` *(Agent)* | **80% 이상 지속 시:** Out Of Memory(OOM) 방지를 위해 인스턴스 타입 증설 검토 |
| **디스크 I/O 및 용량**| `disk_used_percent` | **85% 초과 시:** EBS Volume 크기 축소/증설 및 로그 파일 정기 삭제(logrotate) 적용 |
| **네트워크 트래픽** | `NetworkIn` / `NetworkOut` | 대역폭 고갈 지표 확인 및 CDN(CloudFront) 도입 검토 |

---

### 2. ALB(Application Load Balancer) 및 Auto Scaling 도입 기준

단일 EC2 인스턴스의 한계를 극복하고 고가용성(HA)을 확보하기 위해 아래 조건 충족 시 아키텍처 확장을 수행합니다.

* **ALB 도입 전환 기준:**
  - **단일 장애점(SPOF) 해소:** EC2 장애 시에도 무중단 서비스를 제공해야 하는 경우
  - **HTTPS/SSL 도메인 적용:** EC2 개별 서버 대신 ALB 단에서 SSL Certificate를 일괄 종단(SSL Termination) 처리하고자 할 때
  - **L7 트래픽 분산:** `/api`는 API 서버로, `/`는 Static Web으로 경로 기반 라우팅(Path-based Routing)이 필요한 경우
* **Auto Scaling Group(ASG) 구성 기준:**
  - 평균 `CPUUtilization` **70% 초과** 또는 `RequestCountPerTarget` **1,000건/분 초과** 시 EC2 인스턴스를 Multi-AZ Public/Private Subnet에 자동 확장 및 수축 설정

---

### 3. 비용 추적 및 예산 알림 설정 (Cost Monitoring)

실습 및 운영 과정에서 불필요한 과금을 방지하고 실시간 비용 발생 현황을 추적하기 위해 아래 3가지 과금 모니터링 체계를 구축합니다.

1. **AWS Budgets (예산 알림):**
   * **월 예상 예산:** $1.00 (또는 프리티어 기준 설정)
   * **알림 조건:** 실제 비용 또는 예상 비용(Forecasted Cost)이 예산의 **80%($0.80)**에 도달 시 담당자 이메일로 즉시 경고 알림(Notification) 발송
2. **AWS Cost Explorer & Cost Allocation Tags:**
   * 앞서 설정한 **`Project` / `Env` / `Owner`** 태그를 기반으로 서비스별/담당자별 일일 발생 비용을 다각도로 분석 및 추적
3. **비용 유발 핵심 리소스 주기적 점검 (Cost Leakage Items):**
   * **EIP(Unattached Elastic IP):** EC2에 연결되어 있지 않은 유휴 퍼블릭 IP 즉시 Release
   * **EBS Snapshots / Unattached Volumes:** 인스턴스 삭제 후 남아있는 미사용 EBS 볼륨 수동 삭제
   * **NAT Gateway / ALB:** 실습 종료 후 미사용 상태로 방치되지 않도록 즉시 삭제 확인