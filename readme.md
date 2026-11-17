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
   curl --get "$(terraform output -raw api_endpoint)" \
     --data-urlencode "name=홍길동" \
     -H "Ocp-Apim-Subscription-Key: $(terraform output -raw subscription_key)"
   ```
   위 예시는 Bash용입니다. PowerShell에서는 다음과 같이 실행하세요:
   ```powershell
   $endpoint = terraform output -raw api_endpoint
   $key = terraform output -raw subscription_key
   Invoke-RestMethod -Uri ($endpoint + '?name=' + [uri]::EscapeDataString('홍길동')) -Headers @{'Ocp-Apim-Subscription-Key' = $key}
   ```
   구독 키를 포함하는 기존 `function_endpoint`, `test_curl_command` 출력은 호환성을 위해 유지하되 모두 sensitive 처리합니다. 키와 Terraform 상태/계획 파일을 공유하지 마세요.

7. **인프라 삭제(Destroy):**
   이 프로젝트에서 생성한 모든 리소스를 완전히 삭제하려면 다음 명령어를 실행합니다:
   ```bash
   terraform destroy
   ```

## 개발 및 테스트 가이드라인

- Python 3.12와 Azure Functions Core Tools v4를 사용하세요. 저장소 루트에서 가상환경을 만들고 `python -m pip install -r function_app/requirements.txt`로 의존성을 설치한 뒤 `python -m unittest discover -s tests -v`를 실행하세요.
- 로컬 실행 시 `function_app/local.settings.json`을 생성하세요(커밋/배포 제외):
  ```json
  {"IsEncrypted": false, "Values": {"FUNCTIONS_WORKER_RUNTIME": "python", "AzureWebJobsStorage": "UseDevelopmentStorage=true"}}
  ```
  이 설정을 사용하려면 Azurite를 먼저 실행하세요. 이후 `func start --script-root function_app`으로 시작하고 `http://localhost:7071/api/hello_world?name=Azure`를 호출합니다.
- ZIP 배포에는 `requirements.txt`와 원격 빌드 설정(`SCM_DO_BUILD_DURING_DEPLOYMENT`, `ENABLE_ORYX_BUILD`)이 필요합니다. 현재 구성은 소스만 압축하고 Azure에서 의존성을 설치합니다. `WEBSITE_RUN_FROM_PACKAGE=1`을 별도로 추가하지 마세요.
- APIM 정책은 Named Value의 **display_name**을 참조해야 합니다. Terraform 리소스 참조로 이름과 생성 순서를 연결했으므로 `{{function-key}}` 같은 별도 문자열로 되돌리지 마세요.
- APIM을 통한 경로는 `/hello/`이며 GET을 지원합니다. 함수 직접 경로 `/api/hello_world`는 GET/POST를 지원하지만 Azure에서 직접 호출할 때 함수 키가 필요합니다.
- 이 저장소의 `Developer_1` APIM은 유료이며 생성에 시간이 걸립니다. 새 복제본에는 기존 Terraform 상태가 없으므로 기존 배포를 수정하려면 원래 상태/백엔드를 사용하세요. 새 복제본에서 바로 apply하면 별도 리소스를 생성할 수 있습니다.
- `.terraform.lock.hcl`을 버전 관리하여 검증한 provider 조합을 재사용하세요.

- **로컬에서 함수 실행하기**: 변경 사항을 커밋하기 전에 로컬에서 `func start --script-root function_app` 명령어로 함수 로직을 실행하여 테스트하세요.
- **Python 코딩 컨벤션**: Python 코드는 PEP 8(들여쓰기 4칸, 명확한 식별자 이름, 응답 시 f-string 사용)을 따릅니다. Azure Functions 시그니처 `main(req: func.HttpRequest) -> func.HttpResponse`는 수정하지 말고 그대로 유지하세요.
- **Terraform 코딩 컨벤션**: Terraform 파일은 들여쓰기 2칸을 사용합니다. 프로바이더, 데이터 소스, 리소스를 논리적으로 그룹화하세요. 리소스 이름은 `소문자-케밥-케이스(lower-kebab-case)`를 따르며, Azure 내에서 고유한 이름을 보장하기 위해 `var.prefix`와 무작위 접미사(random suffix)를 결합하여 사용합니다.
- **원격 상태 관리 (Remote State)**: 팀 워크플로우를 위해 원격 상태 백엔드(Remote State Backend) 사용을 권장합니다. 절대 `terraform.tfstate*` 파일을 커밋하지 마세요! 출력된 민감한 정보는 소스 저장소가 아닌 패스워드 매니저 등에 보관하십시오.
- **커밋 및 PR(Pull Request) 가이드**: 커밋 메시지 제목은 약 72자 이내로 짧은 명령형(예: "init")으로 작성합니다. 컨텍스트, 롤백, 수동 작업 단계 등에 대한 설명이 필요할 경우 본문을 추가하세요. PR에는 변경 영향도를 요약하고 현재의 최신 `terraform plan` 결과(비밀 정보 제외)를 첨부하며, 파괴적인 변경 작업이 포함되어 있다면 표시해야 합니다. 상태 마이그레이션이나 자격 증명 교체 같은 후속 작업이 필요할 경우 함께 명시해 주세요.
