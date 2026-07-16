<%@ page contentType="text/html; charset=utf-8" %>
<style>
	.qna-grid-body{
		flex: 1;
		height: 100%;
		overflow: hidden;
		background: #f7f7f7;
	}

	div.qnaWidget {
		height: 100%;
		box-shadow: 4px 4px 5px 2px #bfbfbf;
	}

	div.list-view {
		overflow-y: scroll;
		width: 100%;
		border-bottom: 5px solid #eaeaea
	}
	
	.bbs_qna_question{
		background-color: #ffffff; 
		font-size: 15px; 
		font-weight: bold;
		padding:10px 0px 10px 0px; 
		border: 1px solid #fff;
		border-bottom: 1px solid #d4d4d4;
	}
	
	.bbs_qna_content{
		display: none; 
		background-color: #F5F5F5;
		padding:10px 0px 10px 15px;
		border-bottom: 1px solid #d4d4d4;
	}

</style>


<div class="qna-grid-body list-main-contents">
	<div class="qnaWidget list-view">
		<div id ="grid" class="egene-list">

<%
	RecordSet rs = result.getRecordSet();
	UIList2.Grid grid = ul.grid;

	for(int j = 0; rs.next(); j++) {
%>
					<tr>
						<td>

							<div class="bbs_qna_question" onclick="showContent('bbs_list_<%= rs.get("ebs_id") %>')">

								<img src="/images/icon/bbs_qna_Q.gif" border="0" alt="Question" align="absmiddle">
								<%= rs.get("ebs_title") %>
							</div>

							<div id="bbs_list_<%= rs.get("ebs_id") %>" class="bbs_qna_content">
								<img src="/images/icon/bbs_qna_A.gif" border="0" alt="Answer" align="absmiddle">
								<%= rs.get("ebs_content") %>
							</div>
						</td>
					 </tr>
<%
	}
%>

					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
<%
	if(grid != null && StringUtil.valid(grid.merge_cols)) {

		int srow = 1;
		if(StringUtil.valid(grid.merge_srow)) {

			try {
				srow = Integer.parseInt(grid.merge_srow);
			} catch(NumberFormatException e) {
				Log.biz.err(e.getMessage());
			}
		}

		if(grid.merge_cols.indexOf('-') >= 0) {

			String[] arr = StringUtil.getArray(grid.merge_cols, '-');
			if(arr.length == 2) {
%>
mergeGridCells('table_grid',<%= arr[0] %>, <%= arr[1] %>, <%= srow %>);
<%
			}
		} else if(grid.merge_cols.indexOf(',') >= 0) {

		}
	}
%>
</script>

