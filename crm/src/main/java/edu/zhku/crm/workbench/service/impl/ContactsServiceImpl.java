package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.workbench.domain.Contacts;
import edu.zhku.crm.workbench.domain.Customer;
import edu.zhku.crm.workbench.mapper.ContactsMapper;
import edu.zhku.crm.workbench.mapper.CustomerMapper;
import edu.zhku.crm.workbench.service.ContactsService;
import org.apache.poi.ss.usermodel.DateUtil;
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
@Service("contactsService")
public class ContactsServiceImpl implements ContactsService {

    @Resource
    private ContactsMapper contactsMapper;
    @Resource
    private CustomerMapper customerMapper;

    @Override
    public List<Contacts> queryContactsByCustomerIdForDetail(String customerId) {
        return contactsMapper.selectContactsByCustomerIdForDetail(customerId);
    }

    @Override
    public List<Contacts> queryContactsByName(String name) {
        return contactsMapper.selectContactsByName(name);
    }

    @Override
    public int saveContacts(Contacts contacts) {
        return contactsMapper.insertContacts(contacts);
    }

    @Override
    public int deleteContactsById(String id) {
        return contactsMapper.deleteContactsById(id);
    }

    @Override
    public List<Contacts> queryContactsByConditionForPage(Map<String, Object> map) {
        return contactsMapper.selectContactsByConditionForPage(map);
    }

    @Override
    public int queryCountOfContactsByConditionForPage(Map<String, Object> map) {
        return contactsMapper.selectCountOfContactsByConditionForPage(map);
    }

    @Override
    public void saveCreateContacts(Map<String, Object> map) {
        String customerName = (String) map.get("customerName");
        User user = (User) map.get(Constants.SESSION_USER);

        Customer customer = null;
        if (customerName != "") {
            //根据客户姓名具体查询客户信息
            customer = customerMapper.selectCustomerByName(customerName);

            if (customer == null) {
                customer = new Customer();
                customer.setId(UUIDUtils.getUUID());
                customer.setCreateBy(user.getId());
                customer.setCreateTime(DateUtils.formatDateTime(new Date()));
                customer.setName(customerName);
                customer.setOwner(user.getId());

                //新建
                customerMapper.insertCustomer(customer);
            }
        }

        //如果存在
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtils.getUUID());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateUtils.formatDateTime(new Date()));
        contacts.setFullname((String) map.get("fullname"));
        contacts.setAppellation((String) map.get("appellation"));
        contacts.setJob((String) map.get("job"));
        contacts.setEmail((String) map.get("email"));
        contacts.setMphone((String) map.get("mphone"));
        contacts.setOwner((String) map.get("owner"));
        contacts.setSource((String) map.get("source"));
        if (customer != null) {
            contacts.setCustomerId(customer.getId());
        }
        contacts.setDescription((String) map.get("description"));
        contacts.setContactSummary((String) map.get("contactSummary"));
        contacts.setNextContactTime((String) map.get("nextContactTime"));
        contacts.setAddress((String) map.get("address"));

        contactsMapper.insertContacts(contacts);
    }

    @Override
    public int deleteContactsByIds(String[] id) {
        return contactsMapper.deleteContactsByIds(id);
    }

    @Override
    public Contacts queryContactsById(String id) {
        return contactsMapper.selectContactsById(id);
    }

    @Override
    public void saveEditContacts(Map<String,Object> map) {
        String customerName = (String) map.get("customerName");
        User user = (User) map.get(Constants.SESSION_USER);

        Customer customer = null;
        if (customerName != "") {
            //根据客户姓名具体查询客户信息
            customer = customerMapper.selectCustomerByName(customerName);

            if (customer == null) {
                customer = new Customer();
                customer.setId(UUIDUtils.getUUID());
                customer.setCreateBy(user.getId());
                customer.setCreateTime(DateUtils.formatDateTime(new Date()));
                customer.setName(customerName);
                customer.setOwner(user.getId());

                //新建
                customerMapper.insertCustomer(customer);
            }
        }

        //如果存在
        Contacts contacts = new Contacts();
        contacts.setId((String) map.get("id"));
        contacts.setEditBy(user.getId());
        contacts.setEditTime(DateUtils.formatDateTime(new Date()));
        contacts.setFullname((String) map.get("fullname"));
        contacts.setAppellation((String) map.get("appellation"));
        contacts.setJob((String) map.get("job"));
        contacts.setEmail((String) map.get("email"));
        contacts.setMphone((String) map.get("mphone"));
        contacts.setOwner((String) map.get("owner"));
        contacts.setSource((String) map.get("source"));
        if (customer != null) {
            contacts.setCustomerId(customer.getId());
        }
        contacts.setDescription((String) map.get("description"));
        contacts.setContactSummary((String) map.get("contactSummary"));
        contacts.setNextContactTime((String) map.get("nextContactTime"));
        contacts.setAddress((String) map.get("address"));

        contactsMapper.updateContacts(contacts);
    }

    @Override
    public Contacts queryContactsByIdForDetail(String id) {
        return contactsMapper.selectContactsByIdForDetail(id);
    }
}
