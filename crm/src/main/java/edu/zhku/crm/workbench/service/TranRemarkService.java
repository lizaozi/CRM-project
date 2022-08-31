package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.TranRemark;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/8
 * @description
 */
public interface TranRemarkService {
    List<TranRemark> queryTranRemarkByIdForDetail(String tranId);
}
