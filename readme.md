# Azure API Management 및 Python Function App (Terraform)

## 프로젝트 개요

이 프로젝트는 Terraform을 사용하여 Azure Function App과 Azure API Management(APIM) 인스턴스를 프로비저닝(생성 및 설정)합니다. Function App은 Python으로 작성된 간단한 "Hello World" HTTP 트리거 함수를 호스팅하며, APIM 인스턴스는 해당 함수를 관리형 API로 노출하도록 구성됩니다.

## 아키텍처 (Architecture)

`main.tf` 파일의 Terraform 구성은 다음과 같은 리소스를 정의합니다:

1. 모든 리소스를 포함할 **리소스 그룹 (Resource Group)**
2. Function App 구동을 위한 **스토리지 계정 (Storage Account)**
3. Function App을 위한 **앱 서비스 플랜 (App Service Plan)**
4. Python 기반의 **Function App**
5. **API Management (APIM)** 인스턴스
6. Function App의 정의를 가져오는 APIM 내의 **API**
7. API를 그룹화하기 위한 APIM 내의 **제품 (Product)**
8. API 접근을 허용하기 위한 제품 **구독 (Subscription)**

Python 함수 코드는 `function_app/hello_world` 디렉토리에 위치해 있습니다. 간단한 인사말을 응답으로 반환하는 HTTP 트리거입니다.

## 프로젝트 구조 및 모듈 구성

Terraform 코드는 저장소 루트(최상단)에 위치합니다.
- `main.tf`: Azure 리소스 생성을 담당합니다.
- `provider.tf`: 프로바이더의 버전을 고정합니다.
- `variables.tf`: 변수의 기본값을 정의합니다.
- `outputs.tf`: 생성된 엔드포인트 등의 결과값을 출력합니다.

Azure Function 코드는 `function_app/` 디렉토리 아래에 위치하며 루트에 `host.json`가 있고, `hello_world/` 함수 폴더 내에 `__init__.py`, `function.json` 파일이 포함됩니다. 
*주의: `function_app.zip` 파일은 건드리지 마세요. `terraform apply`를 실행할 때 `archive_file` 데이터 소스에 의해 자동으로 생성됩니다.*

## 필수 조건 (Pre-requisites)

* **Terraform:** 인프라를 코드로 정의하고 관리하기 위해 필요합니다 (IaC).
* **Azure CLI:** Azure 환경에 인증(`az login`)하기 위해 필요합니다.
* **Azure Functions Core Tools:** 로컬 환경에서 함수를 테스트(`func start`)할 때 필요합니다.
* **Python:** Function App 코드를 개발하기 위해 필요합니다.

## 빌드 및 실행 방법

프로젝트에 정의된 리소스를 배포하려면 Terraform과 Azure CLI가 설치 및 구성되어 있어야 합니다.

1. **Azure 인증:**
   ```bash
   az login
   ```
   Terraform 명령을 실행하기 전에 대상 구독(Subscription)을 선택하세요.

2. **Terraform 초기화:**
   ```bash
   terraform init
   ```
   Terraform 작업 디렉토리를 초기화하고, 필요한 프로바이더를 다운로드합니다. 프로젝트를 처음 체크아웃 받았다면 이 명령어를 가장 먼저 실행하세요.

3. **코드 검증 및 포맷팅:**
   ```bash
   terraform fmt -recursive
   terraform validate
   ```
   코드 스타일을 표준화하고 구문 오류나 프로바이더 오류를 잡아내기 위해 사용합니다.

4. **배포 계획(Plan) 생성:**
   ```bash
   terraform plan -out plan.tfplan
   ```
   실행 계획을 생성하여, Terraform이 인프라에 어떤 변경을 가할지 미리 확인할 수 있습니다.

5. **변경 사항 적용(Apply):**
   ```bash
   terraform apply plan.tfplan
   ```
   구성을 원하는 상태로 만들기 위해 변경 사항을 실제 환경에 적용합니다.

6. **API 접근 방법:**
   배포가 완료되면 API 엔드포인트에 접속할 수 있습니다. 엔드포인트 URL과 구독 키는 Terraform 출력(outputs)으로 표시됩니다. 다음 명령어로 다시 확인할 수 있습니다:
   ```bash
   terraform output function_endpoint
   terraform output subscription_key
   ```
   API 엔드포인트 테스트는 아래와 같이 진행합니다:
   ```bash
   curl "$(terraform output -raw function_endpoint)"
   ```
   URL 및 민감한 정보(구독 키 등)는 외부에 유출되지 않도록 안전하게 관리하세요.

7. **인프라 삭제(Destroy):**
   이 프로젝트에서 생성한 모든 리소스를 완전히 삭제하려면 다음 명령어를 실행합니다:
   ```bash
   terraform destroy
   ```

## 개발 및 테스트 가이드라인

- **로컬에서 함수 실행하기**: 변경 사항을 커밋하기 전에 로컬에서 `func start --script-root function_app` 명령어로 함수 로직을 실행하여 테스트하세요.
- **Python 코딩 컨벤션**: Python 코드는 PEP 8(들여쓰기 4칸, 명확한 식별자 이름, 응답 시 f-string 사용)을 따릅니다. Azure Functions 시그니처 `main(req: func.HttpRequest) -> func.HttpResponse`는 수정하지 말고 그대로 유지하세요.
- **Terraform 코딩 컨벤션**: Terraform 파일은 들여쓰기 2칸을 사용합니다. 프로바이더, 데이터 소스, 리소스를 논리적으로 그룹화하세요. 리소스 이름은 `소문자-케밥-케이스(lower-kebab-case)`를 따르며, Azure 내에서 고유한 이름을 보장하기 위해 `var.prefix`와 무작위 접미사(random suffix)를 결합하여 사용합니다.
- **원격 상태 관리 (Remote State)**: 팀 워크플로우를 위해 원격 상태 백엔드(Remote State Backend) 사용을 권장합니다. 절대 `terraform.tfstate*` 파일을 커밋하지 마세요! 출력된 민감한 정보는 소스 저장소가 아닌 패스워드 매니저 등에 보관하십시오.
- **커밋 및 PR(Pull Request) 가이드**: 커밋 메시지 제목은 약 72자 이내로 짧은 명령형(예: "init")으로 작성합니다. 컨텍스트, 롤백, 수동 작업 단계 등에 대한 설명이 필요할 경우 본문을 추가하세요. PR에는 변경 영향도를 요약하고 현재의 최신 `terraform plan` 결과(비밀 정보 제외)를 첨부하며, 파괴적인 변경 작업이 포함되어 있다면 표시해야 합니다. 상태 마이그레이션이나 자격 증명 교체 같은 후속 작업이 필요할 경우 함께 명시해 주세요.
