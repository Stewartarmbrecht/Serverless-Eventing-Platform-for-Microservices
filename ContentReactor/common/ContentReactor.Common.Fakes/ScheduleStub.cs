namespace ContentReactor.Common.Fakes
{
    using System;
    using Microsoft.Azure.WebJobs.Extensions.Timers;

    /// <summary>
    /// Provides a stub class for building a TimerInfo instance to pass to Azure function timer jobs.
    /// </summary>
    public class ScheduleStub : TimerSchedule
    {
        /// <summary>
        /// Implements the GetNextOccurrence to create a fake TimerSchedule.
        /// </summary>
        /// <param name="now">Don't know.</param>
        /// <returns>What evs.</returns>
        public override DateTime GetNextOccurrence(DateTime now)
        {
            throw new NotImplementedException();
        }
    }
}
