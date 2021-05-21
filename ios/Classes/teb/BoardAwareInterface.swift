//
// Created by vicky Leu on 2021/5/19.
//

import Foundation
protocol BoardAwareInterface {
    func onTEBHistroyDataSyncCompleted()
    func addBoardView()
    func removeBoardView()
    func setCanUndo(_ canUndo: Bool)
    func setCanRedo(_ canredo: Bool)
    func addFile(_ fileId: String?) -> TEduBoardFileInfo?
    func onTextComponentStatusChange(_ id: String?, _ status: String?)

}
