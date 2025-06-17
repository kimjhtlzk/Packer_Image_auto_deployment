import sys
import os
import subprocess
import hcl2
import json

# 인자값을 변수로 지정
provider = sys.argv[1]
task = sys.argv[2]

# 워크스페이스 디렉토리 설정
WORKSPACE_DIR = "/game/jenkins/workspace/com2us-packer-pip"
COMMON_VARS = "variables.auto.pkrvars.hcl"
PROVIDER_DIRS = {
    "aws": os.path.join(WORKSPACE_DIR, "aws"),
    "google": os.path.join(WORKSPACE_DIR, "google"),
    "tencent": os.path.join(WORKSPACE_DIR, "tencent_v2")
}

# 병렬 처리 변수
PARALLEL_BUILDS = {
    "aws": "0",
    "google": "0",
    "tencent": "1"
}

# 공통 함수 정의
def run_packer_commands(provider_dir, parallel_builds):
    try:
        os.chdir(provider_dir)  # provider 디렉토리로 이동
    except FileNotFoundError:
        print(f"Error: Directory {provider_dir} not found.")
        sys.exit(1)
  
    build_command = [
        "packer", "build",
        "--force",
        f"-parallel-builds={parallel_builds}",
        f"-var-file={COMMON_VARS}",
        "."
    ]

    try:
        subprocess.run(build_command, check=True)
        print("Packer build completed successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Packer build failed: {e}")
        sys.exit(1)

##############################################################################
# [Google]
def gcloud_auth(provider_dir):
    # HCL 파일을 읽어 리전 정보 및 사용자 정보 추출
    with open(COMMON_VARS, "r") as file:
        data = hcl2.load(file)  # HCL2 파일 파싱

    gcp_project_id = data.get("gcp_project_id", "")

    key_file_path = os.path.join(provider_dir, "packer.json")

    if not os.path.exists(key_file_path):
        print(f"Error: Key file {key_file_path} not found.")
        sys.exit(1)
    try:
        subprocess.run(
            ["gcloud", "auth", "activate-service-account", 
             "packer@gcp-ie3.iam.gserviceaccount.com", 
             f"--key-file={key_file_path}", f"--project={gcp_project_id}"],
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"Error during gcloud authentication: {e}")
        sys.exit(1)  

##############################################################################
# [Update]

def aws_update():
    import boto3
    # HCL 파일을 읽어 리전 정보 및 사용자 정보 추출
    with open(COMMON_VARS, "r") as file:
        data = hcl2.load(file)  # HCL2 파일 파싱

    # aws_access_key, aws_secret_key, aws_region 추출
    aws_access_key = data.get("aws_access_key", "")
    aws_secret_key = data.get("aws_secret_key", "")
    aws_region = data.get("aws_region", "")
    aws_ami_regions = data.get("aws_ami_regions", [])
    aws_ami_users = data.get("aws_ami_users", [])

    # region 병합 (중복 제거)
    all_regions = list(set([aws_region] + aws_ami_regions))

    # 각 리전에서 'com2us'로 시작하는 이미지를 조회
    for region in all_regions:
        # EC2 클라이언트 생성 (리전별로 클라이언트 생성)
        ec2_client = boto3.client(
            'ec2',
            region_name=region,
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_key
        )

        # 'com2us'로 시작하는 이미지 필터링
        response = ec2_client.describe_images(
            Filters=[
                {
                    'Name': 'name',
                    'Values': ['com2us*']
                }
            ]
        )

        # 조회된 이미지 목록 출력 및 공유 작업
        images = response.get('Images', [])
        if images:
            print(f"\nFound the following 'com2us' images in {region}:")
            for image in images:
                print(f"ID: {image['ImageId']}, Name: {image['Name']}")
                
                # 이미지 공유하기 (멀티 계정)
                try:
                    response = ec2_client.modify_image_attribute(
                        ImageId=image['ImageId'],
                        LaunchPermission={
                            'Add': [{'UserId': user_id} for user_id in aws_ami_users]
                        }
                    )
                    print(f"Image {image['ImageId']} shared with accounts: {', '.join(aws_ami_users)}")
                except Exception as e:
                    print(f"Failed to share image {image['ImageId']}: {str(e)}")
                    sys.exit(1)


def google_update():
    print("Running Google Cloud update")

    # gcloud 명령어 실행 (이미지 이름만 출력)
    try:
        output = subprocess.check_output(
            ["gcloud", "compute", "images", "list", "--filter=name:com2us-*", "--format=value(name)"],
        )

        # 결과를 줄 단위로 나누어 이미지 이름만 출력
        images = output.splitlines()  # 각 줄을 나누어 리스트로 만듦

        # 각 이미지에 대해 google.sh 스크립트 실행
        for image in images:
            script_path = os.path.join(provider_dir, "files", "google.sh")
            if os.path.exists(script_path):
                try:
                    subprocess.run([script_path, image], check=True)
                    print(f"Executed {script_path} for image {image}")
                except subprocess.CalledProcessError as e:
                    print(f"Error occurred while executing {script_path} for image {image}: {e}")
            else:
                print(f"Error: {script_path} not found.")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while listing images: {e}")
        sys.exit(1)        

def tencent_update():
    from tencentcloud.common import credential
    from tencentcloud.common.profile.client_profile import ClientProfile
    from tencentcloud.common.profile.http_profile import HttpProfile
    from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
    from tencentcloud.cvm.v20170312 import cvm_client, models
  
    # HCL 파일을 읽어 리전 정보 및 사용자 정보 추출
    with open(COMMON_VARS, "r") as file:
        data = hcl2.load(file)  # HCL2 파일 파싱

    # Tencent 관련 값 추출
    tencent_secret_id = data.get("tc_secret_id", "")
    tencent_secret_key = data.get("tc_secret_key", "")
    tencent_region = data.get("tc_region", "")
    tencent_image_share_accounts = data.get("tc_image_share_accounts", [])
    tencent_image_copy_regions = data.get("tc_image_copy_regions", [])

    # region 병합 (중복 제거)
    all_regions = list(set([tencent_region] + tencent_image_copy_regions))

    # Tencent Cloud 자격 증명 설정
    cred = credential.Credential(tencent_secret_id, tencent_secret_key)
    httpProfile = HttpProfile()
    httpProfile.endpoint = "cvm.tencentcloudapi.com"
    clientProfile = ClientProfile()
    clientProfile.httpProfile = httpProfile

    print("Running Tencent update")

    for region in all_regions:
        try:
            # 클라이언트 생성
            client = cvm_client.CvmClient(cred, region, clientProfile)

            # DescribeImages 요청 생성
            req = models.DescribeImagesRequest()
            params = {
                "Filters": [
                    {
                        "Name": "image-type",
                        "Values": ["PRIVATE_IMAGE"]
                    },
                    {
                        "Name": "image-name",
                        "Values": ["com2us-"]
                    },                    
                ],
                "Limit": 100
            }
            req.from_json_string(json.dumps(params))

            # 이미지 조회 요청
            resp = client.DescribeImages(req)
            response = json.loads(resp.to_json_string())
            img_num = response["TotalCount"]
            
            print(f"Region: {region}, Found {img_num} images starting with 'com2us-'")

            # 이미지 리스트 출력
            for i in range(img_num):
                basic = response['ImageSet'][i]
                img_id = basic['ImageId']
                img_name = basic['ImageName']
                try:
                    # ModifyImageSharePermission 요청 생성
                    req1 = models.ModifyImageSharePermissionRequest()
                    params1 = {
                        "ImageId": img_id,
                        "AccountIds": tencent_image_share_accounts,
                        "Permission": "SHARE"
                    }
                    req1.from_json_string(json.dumps(params1))

                    # 공유 요청 실행
                    resp1 = client.ModifyImageSharePermission(req1)
                    response1 = json.loads(resp1.to_json_string())
                    print(f"{img_name} Shared successfully!", response1)
                except TencentCloudSDKException as err:
                    print(f"Failed to share {img_name}: {err}")

        except TencentCloudSDKException as err:
            print(f"Error occurred in region {region}: {err}")

##############################################################################

# Provider 폴더 확인 및 작업 수행
if provider in PROVIDER_DIRS:
    provider_dir = PROVIDER_DIRS[provider]
    parallel_builds = PARALLEL_BUILDS[provider]

    print(f"\nProvider selected ({provider})")

##############################################################################

    if task == "build":
        print(f"\n{provider} task (build)")
        if provider == "aws":
            run_packer_commands(provider_dir, parallel_builds)
        elif provider == "google":
            gcloud_auth(provider_dir)
            run_packer_commands(provider_dir, parallel_builds)
        elif provider == "tencent":
            run_packer_commands(provider_dir, parallel_builds)
            tencent_update() # 멀티 리전 대응용

##############################################################################

    elif task == "update":
        print(f"\n{provider} task (update)")
        if provider == "aws":
            aws_update()
        elif provider == "google":
            gcloud_auth(provider_dir)            
            google_update()
        elif provider == "tencent":
            tencent_update()

##############################################################################
# [dev]

##############################################################################            
    else:
        print(f"Unknown task: {task}")
        sys.exit(1)
else:
    print(f"Unknown provider: {provider}")
    sys.exit(1)
