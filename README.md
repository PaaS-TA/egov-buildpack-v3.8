# PaaS-TA 전자정부 프레임워크(egovframework) 빌드팩
PaaS-TA에서 구동되는 애플리케이션은 다양한 언어, 프레임워크를 사용하여 개발될 수 있다. 빌드팩은 이처럼 다양한 환경에서 개발된 애플리케이션이 PaaS-TA에서 구동될 수 있게 지원하는 역할을 한다. 전자정부 프레임워크 빌드팩 v3.5는 전자정부 프레임워크 (https://www.egovframe.go.kr/) 를 적용하여 개발된 애플리케이션이 PaaS-TA에서 구동될 수 있도록 지원한다.


### PaaS-TA에 전자정부 프레임워크 빌드팩 등록
PaaS-TA에서 전자정부 빌드팩을 등록하기 위해서는 빌드팩 소스 Clone, 빌드팩 패키지, 업로드의 3가지 절차가 필요하다. 하단에 순서대로 설명을 기재한다.


#### 1. 빌드팩 소스 clone
git 명령어를 이용하여 소스를 clone 한다. git 명령어를 사용하기 위해서는 git의 설치가 요구된디. 사용자의 환경에 맞게 git을 설치한다.

`git clone https://github.com/OpenPaaSRnD/egov-buildpack-v3.5.git`  


#### 2. 빌드팩 패키지
빌드팩 패키지는 clone한 소스를 바탕으로 빌드팩 패키지 파일을 생성하는 단계이다. 빌드팩을 패키지 하기 위해서 ruby와 bundler의 설치가 요구된다. 요구 버전은 Ruby 2.2.4, bundler 1.13.6 이다. 

`bundle install`  
```
...
Bundle complete! 11 Gemfile dependencies, 29 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
```  

`bundle exec rake package OFFLINE=true`  
※ 'OFFLINE=true' 옵션은 오프라인 빌드팩으로 패키징하는 옵션이다. 오프라인 빌드팩은 빌드팩이 동작하는데 필요한 모든 컴포넌트들을 다운로드하여 패키징에 포함시킨다. 오프라인 빌드팩을 사용할 경우, 오프라인 상태에서 애플리케이션 배포가 가능하다.

```
...
Creating build/egov-buildpack-offline-egov3.5.zip
```  

다음 경로에 패키징 파일이 생성된다.
`build/egov-buildpack-offline-egov3.5.zip`


#### 3. 빌드팩 업로드
패키징된 빌드팩을 PaaS-TA에 업로드한다. 이때 PaaS-TA는 빌드팩 업로드 권한을 가진 사용자로 로그인 할 것을 요구한다. 일반 사용자는 빌드팩을 업로드 할 수 없으므로 관리자 계정으로 로그인하여 빌드팩 업로드를 수행한다.

- 빌드팩 업로드  

빌드팩 업로드 명령어는 다음의 형태로 입력하게 되어있다.  
`cf create-buildpack <생성할 이름> <패키지 파일> <우선순위>`  

<생성할 이름> : PaaS-TA에서 사용하는 해당 빌드팩 고유의 이름을 입력한다.  
<패키지 파일> : 패키지된 파일의 경로와 파일명을 입력한다.  
<우선순위> : 검출(detect) 우선순위이다. 일반 Java 빌드팩보다 후순위로 우선순위를 지정한다.  

<div id='notice-01'></div>
※ 기본적으로 빌드팩은 검출 기준을 가지고 있다. 이를 통해 애플리케이션 배포시, 사용자가 빌드팩을 지정해주지 않아도 해당 소스에 맞는 빌드팩을 자동으로 찾아준다. 이떄, 같은 검출 기준을 가진 빌드팩이 여러개 있을 경우에는 우선순위에 따라 가장 우선순위가 높은 빌드팩을 사용하게 된다. 전자정부 프레임워크 빌드팩은 Java 빌드팩과 동일한 검출 기준을 갖고 있기 때문에 전자정부 프레임워크 빌드팩의 우선순위가 Java 빌드팩보다 높을 경우, 빌드팩을 지정하지 않고 배포하는 일반 Java 애플리케이션이 전자정부 프레임워크 빌드팩을 사용하게 된다. 이러한 혼란을 방지하기 위해 전자정부 프레임워크 빌드팩은 Java 빌드팩보다 우선 순위를 낮게 지정한다. (번호가 낮을 수록 우선순위가 높기 때문에 Java 빌드팩보다 높은 번호로 지정한다.)

`cf create-buildpack egov_buildpack_v35 build/egov-buildpack-offline-egov3.5.zip 12`  

```
Creating buildpack egov_buildpack_v35...
OK

Uploading buildpack egov_buildpack_v35...
Done uploading
OK
```

- 업로드 된 빌드팩을 확인  

`cf buildpacks`  

```
buildpack                position   enabled   locked   filename
java_buildpack_offline   1          true      false    java-buildpack-offline-v3.10.zip
staticfile_buildpack     2          true      false    staticfile_buildpack-cached-v1.3.12.zip
java_buildpack           3          true      false    java-buildpack-v3.10.zip
ruby_buildpack           4          true      false    ruby_buildpack-cached-v1.6.27.zip
nodejs_buildpack         5          true      false    nodejs_buildpack-cached-v1.5.22.zip
go_buildpack             6          true      false    go_buildpack-cached-v1.7.14.zip
python_buildpack         7          true      false    python_buildpack-cached-v1.5.11.zip
php_buildpack            8          true      false    php_buildpack-cached-v4.3.21.zip
binary_buildpack         9          true      false    binary_buildpack-cached-v1.0.5.zip
dotnet_core_buildpack    10         true      false    dotnet-core_buildpack-cached-v1.0.4.zip
pinpoint_buildpack       11         true      false    java-buildpack-offline-pinpoint-v2.zip
egov_buildpack_v35       12         true      false    egov-buildpack-offline-egov3.5.zip
```

### 전자정부 프레임워크 빌드팩 사용
PaaS-TA에서 전자정부 프레임워크 빌드팩을 사용하여 애플리케이션을 배포하는 방법을 설명하기 위해 전자정부 프레임워크가 적용된 샘플 애플리케이션을 배포한다.


#### 1. 샘플 애플리케이션 다운로드

- PaaS-TA 팀에서 제공하는 샘플 애플리케이션 다운로드  

>PaaSTA-Sample-Apps : **<https://paas-ta.kr/data/packages/2.0/PaaSTA-Sample-Apps.zip>**  


압축 파일을 다운로드하고 압축을 해제하면 다음 경로에서 샘플 애플리케이션 war 파일과 manifest 파일을 찾을 수 있다.

- 샘플 애플리케이션 확인  

>애플리케이션 war 파일 : Egov/hellot-egov-board/for_push/hello-egov-board-1.0.0.war  
>manifest 파일 : Egov/hellot-egov-board/for_push/manifest.yml


#### 2. Manifest 수정
PaaS-TA 전자정부 프레임워크 빌드팩은 두 가지 WAS(Tomcat/Jboss)중 한 가지 WAS를 선택하여 애플리케이션을 구동시킬 수 있도록 구성되어 있다. 어떤 WAS를 선택할지, manifest 파일에 명시한다.  

- manifest 파일 수정 (Tomcat 선택)  
기본적으로 manifest 파일은 WAS를 Tomcat으로 설정할 수 있도록 작성되어 있다. 최하단 'JBP_CONFIG_COMPONENTS' 옵션에 '[containers: Tomcat]'으로 값을 입력하면 Tomcat을 사용하여 애플리케이션이 배포된다. 또한, 'JBP_CONFIG_COMPONENTS' 값이 존재하지 않는 경우에도 기본값으로 Tomcat을 사용한다.  
※ 값 입력시, 대소문자에 유의한다. 첫 글자만 대문자이다. 'tomcat', 'TOMCAT' 등은 허용하지 않는다.  
```
---
applications:
- name: hello-egov-boardT 
  memory: 1024M
  instances: 1
  path: hello-egov-board-1.0.0.war 
  env:
    JBP_CONFIG_COMPONENTS: '[containers: Tomcat]'
```

- manifest 파일 수정 (Jboss 선택)  
최하단 'JBP_CONFIG_COMPONENTS' 옵션에 '[containers: Jboss]'으로 값을 수정하면 Jboss를 사용하여 애플리케이션이 배포된다.  
※ 값 입력시, 대소문자에 유의한다. 첫 글자만 대문자이다. 'jboss', 'JBOSS' 등은 허용하지 않는다.
```
---
applications:
- name: hello-egov-boardT 
  memory: 1024M
  instances: 1
  path: hello-egov-board-1.0.0.war 
  env:
    JBP_CONFIG_COMPONENTS: '[containers: Jboss]'
```

#### 3. 샘플 애플리케이션 배포
빌드팩을 지정하여 애플리케이션을 배포한다. 애플리케이션 배포시에는 PaaS-TA에 로그인 및 조직과 공간에 대한 target 설정이 되어 있어야 하며, 로그인 된 계정은 해당 조직과 공간에 애플리케이션을 배포할 수 있는 권한을 지니고 있어야 한다.

- 샘플 애플리케이션 디렉토리로 이동  
현재 디렉토리에 애플리케이션 war 파일과 manifest 파일이 존재해야 한다. 

`cd Egov/hellot-egov-board/for_push`

- 애플리케이션 배포  
[상단](#notice-01)에 서술한대로, 샘플 애플리케이션은 빌드팩을 지정하지 않은 경우에는 Java 빌드팩으로 배포되기 때문에 적절한 배포가 이루어지지 않는다. 반드시 업로드한 전자정부 프레임워크 빌드팩을 지정하여 배포한다.

`cf push -b egov_buildpack_v35`
```
...
[ConfigurationUtilsForWAS]       INFO  Configuration from /tmp/buildpacks/67244c9413ffe25f3325b3d9f2548860/config/components.yml modified with: [containers: Tomcat]
...

requested state: started
instances: 1/1
usage: 1G x 1 instances
urls: hello-egov-boardt.115.68.46.186.xip.io
last uploaded: Wed Feb 8 08:40:27 UTC 2017
stack: cflinuxfs2
buildpack: egov_buildpack_v35

     state     since                    cpu      memory         disk           details
#0   running   2017-02-08 05:41:59 PM   158.4%   371.5M of 1G   182.1M of 1G
```

- 애플리케이션 배포 확인  
명령어를 이용하여 애플리케이션의 배포 여부와 상태를 확인한다.

`cf apps`

```
name                requested state   instances   memory   disk   urls
hello-egov-boardT   started           1/1         1G       1G     hello-egov-boardt.115.68.46.186.xip.io
```

- 애플리케이션 접속 확인  
브라우저를 통해 애플리케이션 url로 접속한다.

```
http://hello-egov-boardt.115.68.46.186.xip.io/
```

데이터 베이스 설정을 하지 않았기 때문에 오류 메시지가 나오지만 빌드팩은 정상적으로 동작하는 것이 확인된다.  
![egov_buildpack_image_01]


[egov_buildpack_image_01]:https://github.com/OpenPaaSRnD/Documents-PaaSTA-2.0/blob/master/images/paasta-egov-buildpack/egov_buildpack_image_01.jpg
