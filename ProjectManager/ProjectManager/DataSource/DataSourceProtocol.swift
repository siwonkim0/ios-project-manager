import RxSwift

protocol DataSourceProtocol {
    func append(_ project: Project)
    func delete(_ project: Project)
    func update(_ project: Project)
    func fetch() -> Single<[Project]>
}
