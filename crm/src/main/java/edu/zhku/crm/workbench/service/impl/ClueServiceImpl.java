package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.settings.commons.constants.Constants;
import edu.zhku.crm.settings.commons.utils.DateUtils;
import edu.zhku.crm.settings.commons.utils.UUIDUtils;
import edu.zhku.crm.settings.domain.User;
import edu.zhku.crm.workbench.domain.*;
import edu.zhku.crm.workbench.mapper.*;
import edu.zhku.crm.workbench.service.ClueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

/**
 * @author lzw
 * @date 2022/4/30
 * @description
 */
@Service("clueService")
public class ClueServiceImpl implements ClueService {

    @Resource
    private ClueMapper clueMapper;
    @Resource
    private CustomerMapper customerMapper;
    @Resource
    private ContactsMapper contactsMapper;
    @Resource
    private ClueRemarkMapper clueRemarkMapper;
    @Resource
    private CustomerRemarkMapper customerRemarkMapper;
    @Resource
    private ContactsRemarkMapper contactsRemarkMapper;
    @Resource
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Resource
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Resource
    private TranMapper tranMapper;
    @Resource
    private TranRemarkMapper tranRemarkMapper;

    @Override
    public int saveCreateClue(Clue clue) {
        return clueMapper.insertClue(clue);
    }

    @Override
    public List<Clue> queryAllClueByConditionForPage(Map<String, Object> map) {
        return clueMapper.selectAllClueByConditionForPage(map);
    }

    @Override
    public int queryCountOfClueByCondition(Map<String, Object> map) {
        return clueMapper.selectCountOfClueByCondition(map);
    }

    @Override
    public void deleteClueByIds(String[] ids) {
        clueMapper.deleteClueByIds(ids);
        clueRemarkMapper.deleteClueRemarkByClueIds(ids);
        clueActivityRelationMapper.deleteClueActivityRelationByClueIds(ids);
    }

    @Override
    public Clue queryClueById(String id) {
        return clueMapper.selectClueById(id);
    }

    @Override
    public int editClueById(Clue clue) {
        return clueMapper.updateClueById(clue);
    }

    @Override
    public Clue queryClueByIdForDetail(String id) {
        return clueMapper.selectClueByIdForDetail(id);
    }

    @Override
    public void saveConvertClue(Map<String, Object> map) {
        User user = (User) map.get(Constants.SESSION_USER);
        String clueId = (String) map.get("clueId");
        String isCreateTran = (String) map.get("isCreateTran");

        //根据线索id查询线索信息
        Clue clue = clueMapper.selectClueById(clueId);

        //保存客户信息
        Customer customer = new Customer();
        customer.setId(UUIDUtils.getUUID());
        customer.setOwner(user.getId());
        customer.setName(clue.getCompany());
        customer.setWebsite(clue.getWebsite());
        customer.setPhone(clue.getPhone());
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtils.formatDateTime(new Date()));
        customer.setContactSummary(clue.getContactSummary());
        customer.setNextContactTime(clue.getNextContactTime());
        customer.setDescription(clue.getDescription());
        customer.setAddress(clue.getAddress());
        customerMapper.insertCustomer(customer);

        //保存联系人信息
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtils.getUUID());
        contacts.setOwner(user.getId());
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateUtils.formatDateTime(new Date()));
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setAddress(clue.getAddress());
        contactsMapper.insertContacts(contacts);

        //根据线索id查询线索备注信息
        List<ClueRemark> clueRemarkList = clueRemarkMapper.selectClueRemarkByClueId(clueId);

        //如果线索备注不为空，把线索的备注信息转换到客户备注表中一份和联系人备注表中一份
        if (clueRemarkList != null && clueRemarkList.size() > 0) {

            List<CustomerRemark> crList = new ArrayList<>();
            CustomerRemark cr = null;

            List<ContactsRemark> cotrList = new ArrayList<>();
            ContactsRemark contactsRemark = null;

            for (ClueRemark cur: clueRemarkList) {
                cr = new CustomerRemark();

                cr.setId(UUIDUtils.getUUID());
                cr.setCreateBy(cur.getCreateBy());
                cr.setCreateTime(cur.getCreateTime());
                cr.setEditBy(cur.getEditBy());
                cr.setEditTime(cur.getEditTime());
                cr.setNoteContent(cur.getNoteContent());
                cr.setCustomerId(customer.getId());
                cr.setEditFlag(cur.getEditFlag());
                crList.add(cr);

                contactsRemark = new ContactsRemark();

                contactsRemark.setId(UUIDUtils.getUUID());
                contactsRemark.setCreateBy(cur.getCreateBy());
                contactsRemark.setCreateTime(cur.getCreateTime());
                contactsRemark.setEditBy(cur.getEditBy());
                contactsRemark.setEditTime(cur.getEditTime());
                contactsRemark.setContactsId(contacts.getId());
                contactsRemark.setEditFlag(cur.getEditFlag());
                contactsRemark.setNoteContent(cur.getNoteContent());
                cotrList.add(contactsRemark);
            }
            //批量保存客户备注信息
            customerRemarkMapper.insertCustomerRemarkByList(crList);
            //批量保存联系人备注信息
            contactsRemarkMapper.insertContactsRemarkByList(cotrList);
        }

        //根据线索id查询线索和市场活动的关联关系
        List<ClueActivityRelation> carList = clueActivityRelationMapper.selectClueActivityRelationByClueId(clueId);

        //如果carList不为空
        if (carList != null && carList.size() > 0) {
            //批量插入联系人和市场活动的关联关系信息
            ContactsActivityRelation contactsActivityRelation = null;
            List<ContactsActivityRelation> contactsActivityRelationList = new ArrayList<>();
            for (ClueActivityRelation car : carList) {
                contactsActivityRelation = new ContactsActivityRelation();

                contactsActivityRelation.setId(UUIDUtils.getUUID());
                contactsActivityRelation.setActivityId(car.getActivityId());
                contactsActivityRelation.setContactsId(contacts.getId());

                contactsActivityRelationList.add(contactsActivityRelation);
            }
            contactsActivityRelationMapper.insertContactsActivityRelationByList(contactsActivityRelationList);
        }

        //如果勾选了创建交易
        if ("true".equals(isCreateTran)) {
            //封装参数，用于创建交易
            Tran tran = new Tran();
            tran.setId(UUIDUtils.getUUID());
            tran.setOwner(user.getId());
            tran.setMoney((String) map.get("money"));
            tran.setName((String) map.get("name"));
            tran.setExpectedDate((String) map.get("expectedDate"));
            tran.setCustomerId(customer.getId());
            tran.setStage((String) map.get("stage"));
            tran.setActivityId((String) map.get("activityId"));
            tran.setContactsId(contacts.getId());
            tran.setCreateBy(user.getId());
            tran.setCreateTime(DateUtils.formatDateTime(new Date()));

            tranMapper.insertTran(tran);

            //如果线索备注不为空
            if (clueRemarkList != null && clueRemarkList.size() > 0) {
                //把线索的备注信息转换到交易备注表中一份
                TranRemark tranRemark = null;
                List<TranRemark> tranRemarkList = new ArrayList<>();
                for (ClueRemark cr : clueRemarkList) {
                    tranRemark = new TranRemark();

                    tranRemark.setId(UUIDUtils.getUUID());
                    tranRemark.setNoteContent(cr.getNoteContent());
                    tranRemark.setCreateBy(cr.getCreateBy());
                    tranRemark.setCreateTime(cr.getCreateTime());
                    tranRemark.setEditBy(cr.getEditBy());
                    tranRemark.setEditTime(cr.getEditTime());
                    tranRemark.setEditFlag(cr.getEditFlag());
                    tranRemark.setTranId(tran.getId());

                    tranRemarkList.add(tranRemark);
                }
                tranRemarkMapper.insertTranRemarkByList(tranRemarkList);
            }
        }

        //根据线索id删除线索备注信息
        clueRemarkMapper.deleteClueRemarkByClueId(clueId);
        //根据线索id删除线索和市场活动的关联关系
        clueActivityRelationMapper.deleteClueActivityRelationByClueId(clueId);
        //根据id删除线索
        clueMapper.deleteClueById(clueId);
    }
}
