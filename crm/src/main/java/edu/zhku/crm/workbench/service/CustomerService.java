package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/5
 * @description
 */
public interface CustomerService {
    List<Customer> queryCustomerByConditionForPage(Map<String,Object> map);

    int queryCountOfCustomerByCondition(Map<String,Object> map);

    int saveCustomer(Customer customer);

    int deleteCustomerByIds(String[] ids);

    Customer queryCustomerById(String id);

    int editCustomerById(Customer customer);

    Customer queryCustomerByIdForDetail(String id);

    List<String> queryAllCustomerNameByName(String name);
}
