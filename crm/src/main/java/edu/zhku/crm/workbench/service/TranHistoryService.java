package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.TranHistory;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/8
 * @description
 */
public interface TranHistoryService {
    List<TranHistory> queryTranHistoryByTranIdForDetail(String tranId);
}
