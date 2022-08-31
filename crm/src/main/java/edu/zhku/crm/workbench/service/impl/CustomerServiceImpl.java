package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.Customer;
import edu.zhku.crm.workbench.mapper.CustomerMapper;
import edu.zhku.crm.workbench.service.CustomerService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/5
 * @description
 */
@Service("customerService")
public class CustomerServiceImpl implements CustomerService {

    @Resource
    private CustomerMapper customerMapper;

    @Override
    public List<Customer> queryCustomerByConditionForPage(Map<String, Object> map) {
        return customerMapper.selectCustomerByConditionForPage(map);
    }

    @Override
    public int queryCountOfCustomerByCondition(Map<String, Object> map) {
        return customerMapper.selectCountOfCustomerByCondition(map);
    }

    @Override
    public int saveCustomer(Customer customer) {
        return customerMapper.insertCustomer(customer);
    }

    @Override
    public int deleteCustomerByIds(String[] ids) {
        return customerMapper.deleteCustomerByIds(ids);
    }

    @Override
    public Customer queryCustomerById(String id) {
        return customerMapper.selectCustomerById(id);
    }

    @Override
    public int editCustomerById(Customer customer) {
        return customerMapper.updateCustomerById(customer);
    }

    @Override
    public Customer queryCustomerByIdForDetail(String id) {
        return customerMapper.selectCustomerByIdForDetail(id);
    }

    @Override
    public List<String> queryAllCustomerNameByName(String name) {
        return customerMapper.selectAllCustomerNameByName(name);
    }
}
