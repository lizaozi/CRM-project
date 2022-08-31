package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.ContactsRemark;
import edu.zhku.crm.workbench.mapper.ContactsRemarkMapper;
import edu.zhku.crm.workbench.service.ContactsRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/19
 * @description
 */
@Service("contactsRemarkService")
public class ContactsRemarkServiceImpl implements ContactsRemarkService {

    @Resource
    private ContactsRemarkMapper contactsRemarkMapper;

    @Override
    public List<ContactsRemark> queryContactsRemarkByContactsIdForDetail(String id) {
        return contactsRemarkMapper.selectContactsRemarkByContactsIdForDetail(id);
    }
}
