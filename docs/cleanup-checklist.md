# AWS Resource Cleanup Checklist

실습 종료 후 다음 항목을 순서대로 확인한다.

## EC2

- [x] EC2 인스턴스 종료
- [x] 인스턴스 상태가 Terminated가 되었는지 확인

## EBS

- [x] 연결된 EBS 확인
- [x] 불필요한 EBS 볼륨 삭제
- [x] 미사용 볼륨이 남아 있지 않은지 확인

## Elastic IP

- [x] Elastic IP를 생성했다면 확인
- [x] Elastic IP Release 확인

## Internet Gateway

- [x] VPC와 Internet Gateway 연결 확인
- [x] Internet Gateway Detach
- [x] Internet Gateway 삭제

## Route Table

- [x] Public Subnet 연결 확인
- [x] 불필요한 Route Table 삭제

## Subnet

- [x] Public Subnet 삭제

## VPC

- [x] VPC 삭제

## Billing

- [x] AWS Billing Dashboard 확인
- [x] 실습 리소스 관련 과금 항목이 남아 있지 않은지 확인

## 최종 확인

- [x] EC2 삭제 완료
- [x] EBS 삭제 완료
- [x] Elastic IP Release 완료
- [x] Internet Gateway 삭제 완료
- [x] VPC 삭제 완료
- [x] 과금 위험 리소스가 남아 있지 않음