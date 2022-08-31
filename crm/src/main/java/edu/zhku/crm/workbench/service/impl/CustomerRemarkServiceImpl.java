package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.CustomerRemark;
import edu.zhku.crm.workbench.mapper.CustomerRemarkMapper;
import edu.zhku.crm.workbench.service.CustomerRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
@Service("customerRemarkService")
public class CustomerRemarkServiceImpl implements CustomerRemarkService {

    @Resource
    private CustomerRemarkMapper customerRemarkMapper;

    @Override
    public List<CustomerRemark> queryCustomerRemarkByCustomerIdForDetail(String customerId) {
        return customerRemarkMapper.selectCustomerRemarkByCustomerIdForDetail(customerId);
    }

    @Override
    public int saveCustomerRemark(CustomerRemark remark) {
        return customerRemarkMapper.insertCustomerRemark(remark);
    }

    @Override
    public int deleteCustomerRemarkById(String id) {
        return customerRemarkMapper.deleteCustomerRemarkById(id);
    }

    @Override
    public int editCustomerRemarkById(CustomerRemark remark) {
        return customerRemarkMapper.updateCustomerRemarkById(remark);
    }
}
