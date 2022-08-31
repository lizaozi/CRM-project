package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/5/6
 * @description
 */
public interface ContactsService {
    List<Contacts> queryContactsByCustomerIdForDetail(String customerId);

    List<Contacts> queryContactsByName(String name);

    int saveContacts(Contacts contacts);

    int deleteContactsById(String id);

    List<Contacts> queryContactsByConditionForPage(Map<String,Object> map);

    int queryCountOfContactsByConditionForPage(Map<String,Object> map);

    void saveCreateContacts(Map<String,Object> map);

    int deleteContactsByIds(String[] id);

    Contacts queryContactsById(String id);

    void saveEditContacts(Map<String,Object> map);

    Contacts queryContactsByIdForDetail(String id);
}
