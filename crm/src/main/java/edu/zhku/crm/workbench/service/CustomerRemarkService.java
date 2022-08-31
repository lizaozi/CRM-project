package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.CustomerRemark;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
public interface CustomerRemarkService {
    List<CustomerRemark> queryCustomerRemarkByCustomerIdForDetail(String customerId);

    int saveCustomerRemark(CustomerRemark remark);

    int deleteCustomerRemarkById(String id);

    int editCustomerRemarkById(CustomerRemark remark);
}
