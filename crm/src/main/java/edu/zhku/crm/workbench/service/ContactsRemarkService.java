package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.ContactsRemark;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/19
 * @description
 */
public interface ContactsRemarkService {
    List<ContactsRemark> queryContactsRemarkByContactsIdForDetail(String id);
}
