# 🗓  프로젝트 관리 앱

![projectmana](https://user-images.githubusercontent.com/70251136/171104625-c3f95fe4-b258-4458-98d4-ac4150be5097.png)

> 프로젝트의 CRUD 및 진행 상태 변경을 지원하는 iPad 앱으로, 로컬 & 원격 데이터베이스 저장을 통해 오프라인 환경에서도 프로젝트를 관리할 수 있습니다.

## 프로젝트 소개

### 개발 환경
![](https://img.shields.io/badge/Xcode-13.3-blue) ![](https://img.shields.io/badge/Swift-5.6-orange) ![](https://img.shields.io/badge/RxSwift-6.5.0-red) ![](https://img.shields.io/badge/CocoaPods-1.11.3-red)

### 구동 화면
| CRUD | 네트워크 연결시 로컬, 원격 DB 연동 |
| :--: | :--: |
| <img src="https://i.imgur.com/g2WR7n6.gif" width="600"> | <img src="https://i.imgur.com/eT1PPt3.gif" width="600"> | 
| Local DB - Realm | Remote DB - Firestore |
| <img src="https://i.imgur.com/djEJ79p.png" width="600"> | <img src="https://i.imgur.com/Dv0z97I.png" width="600"> |

 
## 프로젝트 주요 기능

### 프로젝트 CRUD
- Local, Remote 저장소에 TODO List의 대표적 기능 CRUD를 구현하였습니다.

### Long Press를 통한 프로젝트 상태 변경
- 할일을 Long Press Gesture를 통해 TODO, DOING, DONE 세가지 상태로 변경할 수 있도로 구현하였습니다.

### 로컬 저장소 데이터 저장
- Realm을 사용하여 로컬 저장소에 할일 목록, 상태 등을 저장하여 네트워크가 동작하지 않는 상태에서도 정상적으로 동작할 수 있도로 구현하였습니다.

### 원격 저장소 데이터 저장
- Firebase를 사용하여 원격 저장소 할일 목록, 상태 등을 저장하여 네트워크 상태가 정상적인 상황에서 원격 저장소에도 저장, 백업을 할 수 있도록 구현하였습니다.

### 로컬-서버 데이터 동기화
- 만약 네트워크가 연결되어 있지 않다면 원격 저장소(Firebase)에는 저장, 백업을 할 수 없는 상황이기에 로컬 저장소에 저장한 뒤 네트워크가 정상적으로 동작할 시 원격 저장소가 로컬 저장소로부터 동기화되도록 하여 데이터 저장 안정성을 높였습니다.

### 네트워크 연결되지 않은 경우 알림 표시
- 네트워크가 정상적으로 연결되어 있지 않은 경우 알림을 표시하여 사용자 편의성을 높였습니다.

### 날짜를 사용자의 지역, 언어에 맞게 표현

## 학습 키워드

### Database
- Realm을 통한 Local DB구현
- FireBase를 통한 Remote DB 구현

### RxSwift
- RxCocoa : tableView.rx
- Observable
- Traits(Single, Completable)
- BehaviorRelay
- Operators : Filter, Map, FlatMap, zip
