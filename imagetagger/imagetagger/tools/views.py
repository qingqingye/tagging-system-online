from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.urls import reverse
from django.http import Http404, HttpResponse
from django.shortcuts import redirect, get_object_or_404
from django.db import transaction
from django.db.models import Q
from django.template.response import TemplateResponse
from django.contrib import messages
from .models import Tool
from .forms import ToolUploadForm, FileUploadForm
from imagetagger.users.models import Team
from imagetagger.annotations.models import AnnotationType
import os
import xlrd

def tools_enabled(in_function):
    if not settings.TOOLS_ENABLED:
        raise Http404
    return in_function


@tools_enabled
@login_required
def overview(request):
    tools = Tool.objects.select_related('team').order_by(
        'name').filter(
        Q(creator=request.user) | Q(team__members=request.user) | Q(public=True)).distinct()
    delete_tools = [tool.id for tool in tools if tool.has_perm('delete_tool', request.user)]
    edit_tools = [tool.id for tool in tools if tool.has_perm('edit_tool', request.user)]
    tool_form = ToolUploadForm()
    tool_form.fields['team'].queryset = Team.objects.filter(members=request.user)
    return TemplateResponse(request, 'overview.html', {
        'tools': tools,
        'edit_tools': edit_tools,
        'delete_tools': delete_tools,
        'form': tool_form,
        'file_form': FileUploadForm(),
        'tool_upload_notice': settings.TOOL_UPLOAD_NOTICE,
    })

def readXlsx(path,sheetName):
    AnnotationType.objects.all().delete()
    workbook = xlrd.open_workbook(path)
    sheet = workbook.sheet_by_name(sheetName)
    print(sheet.ncols,sheet.nrows)

    for j in range(1, sheet.nrows):
        dictCategory = {}
        for i in range(sheet.ncols):
            dictCategory[sheet.cell_value(0, i)] = sheet.cell_value(j,i)
        annotationTypeSave = AnnotationType(id=dictCategory["Nb of subcategories"],name=dictCategory["L2_Subcategory - TEXT"],active=True,node_count=0,
                                            vector_type=1,enable_concealed=True,enable_blurred=True,
                                            L0=dictCategory["L0"],L1code=dictCategory["L1_Category"],
                                            L1name=dictCategory["L1_Category text"],L2code=dictCategory["L2"],Color = dictCategory["color_sub"])
        annotationTypeSave.save()

@tools_enabled
@login_required
def create_tool(request):
    if request.method == 'POST':
        form = ToolUploadForm(request.POST, request.FILES)
        if form.is_valid():
            tool = form.instance
            # TODO: use team permissions
            if tool.team and request.user not in tool.team.members.all():
                messages.error(
                    request,
                    'You are not permitted to create tools for the team "{}".'
                        .format(tool.team.name))
                return redirect(reverse('tools:overview'))
            with transaction.atomic():
                tool.creator = request.user
                tool.save()
            tool.filename = '{}_{}'.format(tool.id,
                                           request.FILES['file'].name)
            if not os.path.isdir(settings.TOOLS_PATH):
                os.makedirs(settings.TOOLS_PATH)
            final_dir=os.path.join(settings.TOOLS_PATH, tool.filename)
            with open(final_dir, 'wb+') as f:
                for chunk in request.FILES['file']:
                    f.write(chunk)
            messages.success(request, 'The tool was successfully uploaded')
            tool.save()
            readXlsx(final_dir,"L2 final dictionary")
            return redirect(reverse('tools:overview'))

    messages.error(request, 'There was an error with your upload. You can only upload files up to 2 MiB')
    return redirect(reverse('tools:overview'))


@tools_enabled
@login_required
def edit_tool(request, tool_id):
    if request.method == 'POST':
        tool = get_object_or_404(Tool, id=tool_id)
        changed_name = False
        changed_description = False
        changed_public = False
        changed_file = False
        public = 'public' in request.POST.keys()
        if tool.name != request.POST['name']:
            tool.name = request.POST['name']
            changed_name = True
        if tool.description != request.POST['description']:
            tool.description = request.POST['description']
            changed_description = True
        if tool.public != public:
            tool.public = public
            changed_public = True
        file_form = FileUploadForm(request.POST, request.FILES)
        if file_form.is_valid() and 'file' in request.FILES.keys():
            changed_file = True
            old_file_path = os.path.join(settings.TOOLS_PATH, tool.filename)
            tool.filename = request.FILES['file'].name
            file_path = os.path.join(settings.TOOLS_PATH, tool.filename)
            os.remove(old_file_path)
            with open(file_path, 'wb+') as f:
                for chunk in request.FILES['file']:
                    f.write(chunk)
        tool.save()
        msg = 'changed'
        if changed_name:
            msg += ' name'
        if changed_description:
            msg += ' description'
        if changed_public:
            msg += ' public status'
        if changed_file:
            msg += ' file'
        if not (changed_public or changed_description or changed_file or changed_name):
            msg += ' nothing'
        msg += ' in the tool'
        messages.warning(request, msg)
        return redirect(reverse('tools:overview'))


@tools_enabled
@login_required
def delete_tool(request, tool_id):
    if request.method == 'POST':
        tool = get_object_or_404(Tool, id=tool_id)
        if tool.has_perm('delete_tool', request.user):
            file_path = os.path.join(settings.TOOLS_PATH, tool.filename)
            if os.path.exists(file_path):
                os.remove(file_path)
            tool.delete()
        else:
            messages.error(request, 'You do not have the permission to delete the tool!')
    return redirect(reverse('tools:overview'))


@tools_enabled
@login_required
def download_tool(request, tool_id):
    tool = get_object_or_404(Tool, id=tool_id)
    if tool.has_perm('download_tool', request.user):
        file_path = os.path.join(settings.TOOLS_PATH, tool.filename)
        if os.path.exists(file_path):
            with open(file_path, 'rb') as fh:
                response = HttpResponse(fh.read(), content_type="application")
                response['Content-Disposition'] = 'attachment; filename=' + tool.filename
                return response
        else:
            messages.error(request, 'There was an error accessing the tool')
    else:
        messages.error(request, 'You do not have the permission to download the tool!')
    return redirect(reverse('tools:overview'))
