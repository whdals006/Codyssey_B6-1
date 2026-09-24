# AWS Resource Cleanup Checklist

실습 종료 후 다음 항목을 순서대로 확인한다.

## EC2

- [ ] EC2 인스턴스 종료
- [ ] 인스턴스 상태가 Terminated가 되었는지 확인

## EBS

- [ ] 연결된 EBS 확인
- [ ] 불필요한 EBS 볼륨 삭제
- [ ] 미사용 볼륨이 남아 있지 않은지 확인

## Elastic IP

- [ ] Elastic IP를 생성했다면 확인
- [ ] Elastic IP Release 확인

## Internet Gateway

- [ ] VPC와 Internet Gateway 연결 확인
- [ ] Internet Gateway Detach
- [ ] Internet Gateway 삭제

## Route Table

- [ ] Public Subnet 연결 확인
- [ ] 불필요한 Route Table 삭제

## Subnet

- [ ] Public Subnet 삭제

## VPC

- [ ] VPC 삭제

## Billing

- [ ] AWS Billing Dashboard 확인
- [ ] 실습 리소스 관련 과금 항목이 남아 있지 않은지 확인

## 최종 확인

- [ ] EC2 삭제 완료
- [ ] EBS 삭제 완료
- [ ] Elastic IP Release 완료
- [ ] Internet Gateway 삭제 완료
- [ ] VPC 삭제 완료
- [ ] 과금 위험 리소스가 남아 있지 않음