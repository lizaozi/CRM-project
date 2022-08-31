package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.ChartVo;
import edu.zhku.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
public interface TranService {
    List<Tran> queryTranByCustomerIdForDetail(String customerId);

    List<Tran> queryTranByConditionForPage(Map<String,Object> map);

    int queryCountOfTranByConditionForPage(Map<String,Object> map);

    void saveCreateTran(Map<String,Object> map);

    Tran queryTranByIdForDetail(String id);

    List<ChartVo> queryCountOfTranGroupByStage();

    int deleteTranById(String id);

    List<Tran> queryTranByContactsIdForDetail(String contactsId);
}
