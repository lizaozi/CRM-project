package edu.zhku.crm.workbench.mapper;

import edu.zhku.crm.workbench.domain.ContactsRemark;

import java.util.List;

public interface ContactsRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     * 批量保存联系人备注信息
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    int insertContactsRemarkByList(List<ContactsRemark> remarkList);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    int insertSelective(ContactsRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    ContactsRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    int updateByPrimaryKeySelective(ContactsRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_contacts_remark
     *
     * @mbggenerated Wed May 04 22:22:21 CST 2022
     */
    int updateByPrimaryKey(ContactsRemark record);

    /**
     * 根据联系人id查询联系人备注信息
     * @param contactsId
     * @return
     */
    List<ContactsRemark> selectContactsRemarkByContactsIdForDetail(String contactsId);
}