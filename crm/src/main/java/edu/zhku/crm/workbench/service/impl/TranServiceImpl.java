package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.workbench.domain.*;
import edu.zhku.crm.workbench.mapper.CustomerMapper;
import edu.zhku.crm.workbench.mapper.TranHistoryMapper;
import edu.zhku.crm.workbench.mapper.TranMapper;
import edu.zhku.crm.workbench.service.TranService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
@Service("tranService")
public class TranServiceImpl implements TranService {

    @Resource
    private TranMapper tranMapper;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private TranHistoryMapper tranHistoryMapper;

    @Override
    public List<Tran> queryTranByCustomerIdForDetail(String customerId) {
        return tranMapper.selectTranByCustomerIdForDetail(customerId);
    }

    @Override
    public List<Tran> queryTranByConditionForPage(Map<String, Object> map) {
        return tranMapper.selectTranByConditionForPage(map);
    }

    @Override
    public int queryCountOfTranByConditionForPage(Map<String, Object> map) {
        return tranMapper.selectCountOfTranByConditionForPage(map);
    }

    @Override
    public void saveCreateTran(Map<String, Object> map) {
        String customerName = (String) map.get("customerName");
        User user = (User) map.get(Constants.SESSION_USER);
        //根据客户名称查询是否已经存在
        Customer customer = customerMapper.selectCustomerByName(customerName);
        //如果客户不存在，则创建
        if (customer == null) {
            customer = new Customer();
            customer.setId(UUIDUtils.getUUID());
            customer.setOwner(user.getId());
            customer.setCreateBy(user.getId());
            customer.setCreateTime(DateUtils.formatDateTime(new Date()));
            customer.setName(customerName);

            customerMapper.insertCustomer(customer);
        }

        //如果存在
        Tran tran = new Tran();
        tran.setId(UUIDUtils.getUUID());
        tran.setCreateBy(user.getId());
        tran.setCreateTime(DateUtils.formatDateTime(new Date()));
        tran.setOwner((String) map.get("owner"));
        tran.setMoney((String) map.get("money"));
        tran.setName((String) map.get("name"));
        tran.setExpectedDate((String) map.get("expectedDate"));
        tran.setCustomerId(customer.getId());
        tran.setStage((String) map.get("stage"));
        tran.setType((String) map.get("type"));
        tran.setSource((String) map.get("source"));
        tran.setActivityId((String) map.get("activityId"));
        tran.setContactsId((String) map.get("contactsId"));
        tran.setDescription((String) map.get("description"));
        tran.setContactSummary((String) map.get("contactSummary"));
        tran.setNextContactTime((String) map.get("nextContactTime"));

        tranMapper.insertTran(tran);

        //保存交易历史记录
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtils.getUUID());
        tranHistory.setCreateBy(user.getId());
        tranHistory.setCreateTime(DateUtils.formatDateTime(new Date()));
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setStage(tran.getStage());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setTranId(tran.getId());

        tranHistoryMapper.insertTranHistory(tranHistory);
    }

    @Override
    public Tran queryTranByIdForDetail(String id) {
        return tranMapper.selectTranByIdForDetail(id);
    }

    @Override
    public List<ChartVo> queryCountOfTranGroupByStage() {
        return tranMapper.selectCountOfTranGroupByStage();
    }

    @Override
    public int deleteTranById(String id) {
        return tranMapper.deleteTranById(id);
    }

    @Override
    public List<Tran> queryTranByContactsIdForDetail(String contactsId) {
        return tranMapper.selectTranByContactsIdForDetail(contactsId);
    }
}
