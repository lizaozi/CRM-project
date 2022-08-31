package edu.zhku.crm.workbench.mapper;

import edu.zhku.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     * 根据线索id删除线索和市场活动的关联关系
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    int deleteClueActivityRelationByClueId(String clueId);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    int insert(ClueActivityRelation record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    int insertSelective(ClueActivityRelation record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    ClueActivityRelation selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    int updateByPrimaryKeySelective(ClueActivityRelation record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_activity_relation
     *
     * @mbggenerated Mon May 02 17:01:07 CST 2022
     */
    int updateByPrimaryKey(ClueActivityRelation record);

    /**
     * 批量保存创建的线索和市场活动的关联关系
     * @param list
     * @return
     */
    int insertClueActivityRelationByList(List<ClueActivityRelation> list);

    /**
     * 根据clueid和activityid解除关联
     * @param relation
     * @return
     */
    int deleteClueActivityRelationByClueIdActivityId(ClueActivityRelation relation);

    /**
     * 根据线索id查询线索和市场活动的关联关系
     * @param clueId
     * @return
     */
    List<ClueActivityRelation> selectClueActivityRelationByClueId(String clueId);

    /**
     * 根据线索id批量删除线索和市场活动的关联关系
     * @param clueId
     * @return
     */
    int deleteClueActivityRelationByClueIds(String[] clueId);
}