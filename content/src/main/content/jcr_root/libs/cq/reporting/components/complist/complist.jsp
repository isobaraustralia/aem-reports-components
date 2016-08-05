<html>
<%@page session="false"%><%@include file="/libs/wcm/global.jsp"%>
<%@ page import="javax.jcr.*, com.day.cq.commons.Externalizer,
    java.util.Map, 
                java.util.HashMap, 
            com.day.cq.search.Predicate,
            com.day.cq.search.PredicateGroup,
            com.day.cq.search.Query,
            com.day.cq.search.QueryBuilder,
            com.day.cq.search.result.SearchResult,
		    javax.jcr.Session,
org.apache.sling.api.scripting.SlingScriptHelper,
java.text.MessageFormat,
com.day.cq.search.facets.Facet,
com.day.cq.search.result.Hit,
com.day.cq.search.result.ResultPage,
com.day.cq.search.result.SearchResult,
java.util.Date,
java.util.Arrays,
				java.util.Iterator,java.io.IOException, org.apache.commons.lang3.StringEscapeUtils"%>

<html>
<head>
<%

String title=(String) properties.get("jcr:title", "");

%>
<title><%= StringEscapeUtils.escapeHtml4(title) %>
</title>
    <cq:includeClientLib categories="report.complist" />
</head>

<body>
<style>
.number {
    text-align:right;
    height: 40px;
}

.total {
    font-weight:800;
}

.bar {
    height: 24px;
    padding:0;
    border:solid 1px #c0c0c0;
    background: #fff url(/libs/cq/reporting/components/diskusage/bar.gif) repeat-x;
}
</style>

<script src="/libs/cq/ui/resources/cq-ui.js" type="text/javascript"></script>
<h1><%= StringEscapeUtils.escapeHtml4(title) %></h1>

<%!


public void dumpInfo2(JspWriter out, org.apache.sling.api.scripting.SlingScriptHelper sling,Session session) throws IOException,RepositoryException {
    //org.apache.sling.api.scripting.SlingScriptHelper _sling = (org.apache.sling.api.scripting.SlingScriptHelper)  pageContext.getAttribute("sling");
    //Session session = slingRequest.getResourceResolver().adaptTo(Session.class);


// create query description as hash map (simplest way, same as form post)
    Map<String, String> map = new HashMap<String, String>();

    /*
p.or=true
0_property=jcr:primaryType
0_property.value=cq:Component
1_property=jcr:primaryType
1_property.value=cq:VirtualComponent
orderby=componentGroup
orderby.sort=asc
p.hits=full
p.limit=-1

*/

// create query description as hash map (simplest way, same as form post)
    map.put("path", "/");
    map.put("p.or", "true");

    map.put("0_property", "jcr:primaryType");
    map.put("0_property.value", "cq:Component");
    map.put("1_property", "jcr:primaryType");
    map.put("1_property.value", "cq:VirtualComponent");

    map.put("orderby", "componentGroup");
    map.put("orderby.sort", "asc");

    // can be done in map or with Query methods
    map.put("p.offset", "0"); // same as query.setStart(0) below
    map.put("p.limit", "-1"); // same as query.setHitsPerPage(20) below

	QueryBuilder queryBuilder =  sling.getService(QueryBuilder.class);

    Query query = queryBuilder.createQuery(PredicateGroup.create(map), session);
    query.setStart(0);


    SearchResult result = query.getResult();


    long totalMatches = result.getTotalMatches();

    out.write(MessageFormat.format("<h2>Total: {0}</h2><br><br>",totalMatches));
	out.write("<table id=components class=dataTable>");

        out.write(
            MessageFormat.format("<thead><tr><th>{0}</th><th>{1}</th><th>{2}</th><th>{3}</th><th>{4}</th><th>{5}</th><th>{6}</th><th>{7}</th><th>{8}</th><th>{9}</th><th>{10}</th><th>{11}</th><th>{12}</th></tr></thead>",
                            "Component Group",
                            "Title",
                         	"Description",
                         	"Created",
                         	"Allowed Parents",
                         	"Resource Type",
                         	"Sling Resource Type",
                         	"Sling Resource Super Type",
                         	"Path",
                         "Has Icon",
                         "Has Classic Dialog",
                         "Has Dialog",
                         "Has Design Dialog"
                            )
            );

	out.write("<tbody>");
    // iterating over the results
    for (Hit hit : result.getHits()) {

        ValueMap vm = hit.getProperties();
		Resource r = hit.getResource();

		boolean hasIcon = r.getChild("icon.png") == null;
        boolean hasDialog = r.getChild("dialog") == null;
        boolean hasCQDialog = r.getChild("cq:dialog") == null;
        boolean hasDesignDialog = r.getChild("design_dialog") == null;

        out.write(
            MessageFormat.format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td>{8}</td><td>{9}</td><td>{10}</td><td>{11}</td><td>{12}</td></tr>",
                            vm.get("componentGroup","&nbsp;"),
                            vm.get("jcr:title","&nbsp;"),
                         	vm.get("jcr:description","&nbsp;"),
                            vm.get("jcr:created","&nbsp;"),
                         	Arrays.toString(vm.get("allowedParents",new String[0])).replace("[","").replace("]","&nbsp;"),
                            vm.get("jcr:primaryType","&nbsp;"),
                         	vm.get("sling:resourceType","&nbsp;"),
                         	vm.get("sling:resourceSuperType","&nbsp;"),
                         	hit.getPath(),
                            hasIcon,
                            hasDialog,
                            hasCQDialog,
                            hasDesignDialog
                           )
                  );


    }
    out.write("</tbody>");
    out.write("</table>");

}
%>

    <button onclick="$('#components').DataTable();">Convert to DataTable</button>

<div>

<%

    org.apache.sling.api.scripting.SlingScriptHelper _sling = (org.apache.sling.api.scripting.SlingScriptHelper)  pageContext.getAttribute("sling");
    Session session = slingRequest.getResourceResolver().adaptTo(Session.class);


dumpInfo2(out,sling,session);

%>
</div>

</body>
</html>

