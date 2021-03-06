/*
 * Copyright (C) 2009-2012, Gostai S.A.S.
 *
 * This software is provided "as is" without warranty of any kind,
 * either expressed or implied, including but not limited to the
 * implied warranties of fitness for a particular purpose.
 *
 * See the LICENSE file for more information.
 */

#include <libport/cassert>

#include <runner/job.hh>
#include <object/code.hh>
#include <urbi/object/job.hh>
#include <urbi/object/executable.hh>

#include <eval/exec.hh>

namespace urbi
{
  namespace object
  {
    rObject Executable::operator()(object::objects_type)
    {
      pabort("Should never be here");
    }

    Executable::Executable()
    {
      proto_add(Object::proto);
    }

    Executable::Executable(rExecutable model)
    {
      proto_add(model);
    }

    runner::Job*
    Executable::make_job(rLobby lobby,
                         sched::Scheduler& sched,
                         const objects_type& args,
                         libport::Symbol name)
    {
      runner::Job* j = new runner::Job(lobby, sched);
      j->name_set(name);
      j->set_action(eval::exec(this, args));
      return j;
    }

    URBI_CXX_OBJECT_INIT(Executable)
    {}
  }
}
