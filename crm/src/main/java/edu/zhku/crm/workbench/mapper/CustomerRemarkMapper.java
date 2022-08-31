package edu.zhku.crm.workbench.mapper;

import edu.zhku.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     * 根据id删除备注信息
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    int deleteCustomerRemarkById(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     * 批量保存客户备注信息
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    int insertCustomerRemarkByList(List<CustomerRemark> remarkList);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    int insertSelective(CustomerRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    CustomerRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    int updateByPrimaryKeySelective(CustomerRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_customer_remark
     * 根据id更新客户备注信息
     *
     * @mbggenerated Wed May 04 22:10:54 CST 2022
     */
    int updateCustomerRemarkById(CustomerRemark record);

    /**
     * 根据customerId查询备注信息
     * @param customerId
     * @return
     */
    List<CustomerRemark> selectCustomerRemarkByCustomerIdForDetail(String customerId);

    /**
     * 插入客户备注信息
     * @param remark
     * @return
     */
    int insertCustomerRemark(CustomerRemark remark);
}